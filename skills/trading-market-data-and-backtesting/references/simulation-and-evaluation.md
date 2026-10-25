# Simulation and Evaluation

## Fill models

A backtest fill model answers "what price could this order realistically have gotten?" — and the pessimistic answer is the useful one:

| Order type | Defensible default | Why |
|---|---|---|
| market | next bar's open + slippage | you trade after the signal, into the next available price |
| limit | filled only if the bar *after* the order's placement trades through the limit; conservative variant requires `low <= limit - margin` | touching the limit is not a fill — queue position exists |
| stop | triggered at next-bar breach, filled at max(trigger, open) with slippage | gaps through stops fill worse than the stop price |

Two rules prevent the classic optimism:

1. **never fill at the bar's extreme** for an intrabar signal: filling a buy at the bar's low means the simulation knew the low in advance;
2. **partial fills are real**: if the bar's volume is small relative to the order, fill a fraction (volume-based cap) and carry the remainder — or at minimum, size-limit the strategy so the assumption holds.

```ruby
class ConservativeFillModel
  def initialize(slippage_bps:, fee_model:)
    @slippage = Rational(slippage_bps, 10_000)
    @fees = fee_model
  end

  def fill_market(intent, next_bar)
    price = next_bar.open
    price *= (1 + @slippage) if intent.side == :buy
    price *= (1 - @slippage) if intent.side == :sell

    Fill.new(price: price, quantity: intent.quantity, fees: @fees.for(price, intent.quantity))
  end

  def fill_limit(intent, subsequent_bars)
    subsequent_bars.each do |bar|
      if intent.side == :buy && bar.low <= intent.price * (1 - FILL_MARGIN)
        return Fill.new(price: intent.price, quantity: intent.quantity, fees: @fees.for(intent.price, intent.quantity))
      end
    end
    nil   # not filled this evaluation step: an outcome, not an error
  end
end
```

## Fees and slippage

PnL arithmetic rules come from the financial data integrity skill; the simulation-specific rules are:

- fees computed on every simulated fill with the same `FeeSchedule` the live path uses — a backtest with its own fee arithmetic is a different product;
- slippage is a stated parameter (basis points, or a volume-aware model), reported with results, and sensitivity-checked: run the backtest at 0, 1x, and 2x slippage and watch whether the strategy survives its own costs;
- latency can be modeled the same way — decisions at `T` execute at `T + latency` — an honest backtest of an intraday strategy includes it.

Results that omit fees or slippage are labeled as such everywhere they appear ("gross of costs"), because a gross number wearing a net costume is the most quoted wrong number in this domain.

## Live/backtest parity

Divergence between simulation and live behavior is tracked as a first-class artifact:

- run the same strategy logic through the backtest engine and a replayed/live path; same intents from the same data is the parity invariant for the strategy layer;
- fill divergence is expected (live fills beat and miss the model); what is tracked is its **distribution and drift** — live fills consistently better than modeled is fine, consistently worse is a model bug;
- the parity report compares, per period: signals (should match on identical data), fills (priced differences with causes), fees (exact), and PnL (decomposed into price, fee, and slippage effects).

## Deterministic replay

Replay determinism is a tested property, not a hope:

```ruby
class Backtest
  def initialize(series:, strategy:, fills:, ledger:, seed: 0)
    @series = series
    @strategy = strategy
    @fills = fills
    @ledger = ledger
    @rng = Random.new(seed)          # the only randomness source, seeded
  end

  def run
    @series.each_session do |time|
      history = @series.before(time)
      @strategy.decide(as_of: time, history: history).each do |intent|
        fill = @fills.fill(intent, @series.bars_after(time))
        @ledger.record(intent, fill) if fill
      end
    end
    @ledger
  end
end

# The determinism test: same inputs, same seed, byte-identical results.
assert_equal run_a.digest, Backtest.new(**same_inputs).run.digest
```

Determinism rules: inputs immutable (pinned fixtures, recorded dataset versions), all randomness through one seeded generator, no wall-clock or network access inside the simulation, and outputs hashed/digested for comparison. A replay that "mostly" reproduces is not a replay.

## Out-of-sample evaluation

The evaluation protocol that keeps results honest:

1. **split before tuning**: chronological train/validation/test split defined once, in configuration, before any parameter search — the split is data, established before the strategy is;
2. **tune on train, select on validation** — as many rounds as useful, logged;
3. **holdout spent once**: the test set is evaluated exactly once, for the final report. A second evaluation after changes is a new experiment with a contaminated holdout; a fresh holdout must be quarantined for it;
4. **walk-forward for temporal strategies**: optimize on window [t0, t1], test on [t1, t2], roll — reported as the sequence of out-of-sample segments, not their tuned aggregate;
5. **report assumptions with numbers**: costs, fill model, universe, data versions, gaps encountered — a result without its assumptions cannot be audited and is not evidence.

The honest summary states what was measured: "out-of-sample over N segments, costs included, no post-hoc selection" — and the repository's versioned configurations make the claim checkable.
