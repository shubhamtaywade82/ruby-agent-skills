# Paper/Live Separation, Gates, and Testing

## Paper/live separation

Paper and live trading are two implementations of one execution contract: same intent table, same state machine, same event consumer, same reconciliation loop, different venue. The differences that must stay *implementation-only*:

| Layer | Shared | Deliberately different |
|---|---|---|
| intent model + machine | yes | never |
| gateway interface | yes | `Gateway::Paper`, `Gateway::Live` |
| serialization/validation of orders | yes | never |
| event consumption and fill application | yes | never |
| credentials | no (paper has none) | live-only, environment-scoped |
| rate limits, sessions, venue quirks | no | implementation detail inside each gateway |

Paper is the contract test bed. The moment paper mode simplifies validation, reorders events, or skips a state, it stops proving anything about live behavior — the paper gateway must implement the *same* interface with the same error classes, including `AmbiguousOutcome` (simulated timeouts are what make paper tests honest).

```ruby
module Gateway
  class Paper
    # Same contract as Gateway::Live, including failure classes.
    def place_order(client_order_id:, **attrs)
      simulate_ambient_failure!(client_order_id)   # occasional AmbiguousOutcome
      PaperBook.instance.execute(client_order_id, **attrs)
    end
  end
end
```

## Fail-closed gates

The live switch fails closed. Concretely:

- **default off**: a fresh deploy with no configuration places no live orders, ever;
- **explicit and narrow**: one switch naming account/venue, not a global flag accidentally enabling everything;
- **gated by risk state**: live mode requires healthy feeds, fresh reference data, and risk limits present — the switch alone is not permission;
- **observable**: enabling/disabling emits an audit event and an alert; silent mode changes are incidents by definition;
- **tested both ways**: the test suite asserts live submission is unreachable when the switch is off, not merely that paper is the default.

```ruby
class Execution
  class LiveGate
    def initialize(config:, feed_health:, risk_limits:)
      @config = config
      @feed_health = feed_health
      @risk_limits = risk_limits
    end

    def assert_live_allowed!
      unless @config.live_trading_enabled?
        raise LiveTradingDisabled, "live trading is off for this environment"
      end
      unless @feed_health.all_fresh?
        raise ExecutionBlocked, "cannot trade live: #{@feed_health.stale_feeds.join(', ')} stale"
      end
      unless @risk_limits.present?
        raise ExecutionBlocked, "cannot trade live: risk limits unresolved"
      end
    end
  end
end
```

The **risk gate** in front of every submission is the same philosophy with more inputs. It fails closed when any required input is missing, stale, or inconsistent:

- price freshness beyond a per-instrument threshold blocks (see the external stream ingestion skill's freshness contracts);
- unknown or stale position blocks — sizing from a stale position is how "one lot" becomes "ten lots";
- capital/exposure limits resolve to a number or block; a limit that cannot be computed is a limit that does not pass;
- circuit breakers (loss-per-day, error-rate, order-rate) open and block new submissions while alerting.

```ruby
class RiskGate
  def assert_submittable!(intent)
    price = market_data.last_price(intent.symbol)
    raise ExecutionBlocked, "no fresh price for #{intent.symbol}" if price.nil? || price.stale?

    position = positions.current(intent.symbol)
    raise ExecutionBlocked, "position unknown for #{intent.symbol}" if position.nil?

    raise ExecutionBlocked, "quantity exceeds exposure limit" unless exposure.allows?(intent, position)
    true
  end
end
```

What a risk gate is not: a validation on the form, a warning, a log line, or an advisory. It raises, the submission does not happen, and the intent records why.

## Execution testing

Execution tests are adversarial by design, driven through a fake gateway that implements the whole contract including failures:

```ruby
class FakeVenue
  attr_reader :orders, :execution_reports

  def initialize
    @orders = {}
    @execution_reports = []
    @scripted_failures = {}
  end

  def script_failure(client_order_id, error)
    @scripted_failures[client_order_id] = error
  end

  def place_order(client_order_id:, **attrs)
    raise @scripted_failures.fetch(client_order_id) if @scripted_failures.key?(client_order_id)

    orders[client_order_id] = attrs.merge(status: "open", filled: BigDecimal("0"))
    acknowledge(client_order_id)
  end

  def fill(client_order_id, quantity:, price:)
    order = orders.fetch(client_order_id)
    order[:filled] += quantity
    execution_reports << { client_order_id: client_order_id, exec_id: SecureRandom.uuid,
                           quantity: quantity, price: price }
  end
end
```

The adversarial cases every execution suite needs:

1. **double submission**: the same intent submitted twice (job retry, double-click, replayed event) — exactly one order at the venue;
2. **timeout-then-filled**: submission times out, reconciliation finds the order live, a fill arrives — final state correct, no second order, no double count;
3. **duplicate fill event**: the same exec identity delivered twice — applied once;
4. **out-of-order reports**: fill arrives before acknowledgement — absorbed/reconciled per policy, totals still balance;
5. **cancel race**: cancel confirmed after a partial fill — final state `cancelled` with the partial quantity intact;
6. **gate failures**: stale price, missing position, circuit open — submission blocked with the reason recorded on the intent;
7. **live switch off**: with the gate disabled, no code path reaches `Gateway::Live` — asserted by routing the gateway selection through the gate in tests.

```ruby
test "timeout then filled reconciles without a second order" do
  venue = FakeVenue.new
  venue.script_failure(intent.client_order_id, Gateway::AmbiguousOutcome.new)
  # The gateway 'received' the order anyway — the ambiguous window is real.
  venue.orders[intent.client_order_id] = { status: "open", filled: BigDecimal("0") }

  submit_order.call(intent)   # raises/records outcome_unknown

  assert_equal "outcome_unknown", intent.reload.state
  venue.fill(intent.client_order_id, quantity: intent.quantity, price: intent.limit_price)
  Execution::ReconcileIntentJob.perform_now(intent.id)

  assert_equal "filled", intent.reload.state
  assert_equal 1, venue.orders.length          # the whole point
end
```

Live accounts are never test fixtures. A sandbox/venue simulation environment, where it exists, is a deployment target for manual drills — not a CI step that can leave orders behind when it fails halfway.
