# Intent and Identity

## Durable intent before side effects

An order that exists only in memory cannot be deduplicated, recovered, audited, or reconciled. The intent record is the contract between a decision and the world: before any submission call, the intent exists in the database with everything needed to reproduce, inspect, and recover the execution.

A minimal order intent carries:

| Field | Why |
|---|---|
| symbol, side, quantity, order type, limit price | the decision itself |
| client_order_id | deterministic identity, unique across the venue |
| state | the guarded machine (`draft -> submitted -> acknowledged -> ...`) |
| strategy/session reference | why this order exists, for audit and analysis |
| created/updated timestamps | ordering evidence for disputes and debugging |

The generation rule that matters — **intent first, then submit, never the reverse**:

```ruby
# Correct: the row exists before the call.
intent = OrderIntent.create!(
  symbol: signal.symbol, side: signal.side, quantity: signal.quantity,
  client_order_id: OrderIntentId.for(signal), state: "draft"
)
SubmitOrder.new(gateway: gateway, risk_gate: risk).call(intent)
```

The wrong version — building the order, calling the gateway, then persisting "what we did" — cannot answer the crash-window question ("did we place an order?") and cannot stop a retry from placing a second one.

## Client order ID generation

The client order ID is the deduplication key at the venue and the join key for reconciliation. It must be:

1. **deterministic per intent**: derived from the intent's identity, not fresh randomness per attempt;
2. **unique per venue and account**: namespaced so two strategies or two accounts cannot collide;
3. **stable across retries, replays, and restarts**: the same logical order always carries the same ID.

```ruby
module OrderIntentId
  # Deterministic: same signal + session => same ID; collisions are a uniqueness
  # error at the venue, which is exactly the deduplication we want.
  def self.for(signal)
    digest = OpenSSL::Digest::SHA256.new
    digest.update(signal.session_id.to_s)
    digest.update(":")
    digest.update(signal.decision_id.to_s)
    "ras-#{signal.account_id}-#{digest.hexdigest[0, 20]}"
  end
end
```

Patterns that work: session+decision hashes (as above), or the intent row's UUID issued inside the creating transaction. Patterns that do not: `SecureRandom.uuid` regenerated inside the retry loop (new identity per attempt defeats deduplication), timestamps alone (same millisecond = same order = silent merge), and sequence numbers from an unsynchronized source.

Some venues reject unknown IDs only within a window (the broker forgets an ID after N hours or after order expiry). That limitation is a documented property of the venue: it shortens the deduplication horizon, it does not excuse regenerating IDs — after the horizon, a *new intent* is created deliberately, with an audit note referencing the original.

## Duplicate prevention at three layers

Duplicates are prevented in depth, because any single layer fails in some window:

1. **database**: unique index on `[venue, client_order_id]` — the hard guarantee that one identity equals at most one order;
2. **transition guard**: `submit` is a legal transition only from `draft`; a second submission raises instead of sending;
3. **venue**: the broker deduplicates on the client order ID within its documented horizon — the backstop, not the plan.

```ruby
class OrderIntent < ApplicationRecord
  # schema: unique index ON order_intents (venue, client_order_id)
  def transition!(event, **)
    # guarded state machine; see the state machine skill
  end
end
```

The layer people forget: **job frameworks retry**. An `ActiveJob` wrapping a submission retries on failure by default. A retried job that already submitted must hit the transition guard and become a no-op-with-audit, not a second order. Wrap submissions so retries are classified (see the retries reference), and set `retry_on` deliberately for only the definitely-not-executed class.

## Amend and cancel identities

Cancels and amends are requests with their own uncertainty windows, not method calls that "worked" because they returned.

- A cancel request carries its own identity (or the venue's cancel-request semantics keyed to the client order ID), and is confirmed by the venue's cancel-acknowledged event — a cancel is *pending* until confirmed, and the order may fill in the race window;
- an amend that times out leaves the order in either state (amended or original) — reconcile from the venue's current order state, never by re-amending;
- "cancel/replace" at venues that implement it as two orders must preserve the linking identity so reconciliation can pair them.

```ruby
def request_cancel(intent)
  CancelRequest.create!(intent: intent, request_id: CancelRequestId.for(intent), state: "pending")
  response = @gateway.cancel_order(client_order_id: intent.client_order_id)
  # The intent's state changes on the venue's confirmation event, not here.
rescue Gateway::TimeoutError, Gateway::ConnectionError
  # unknown: did the cancel land? reconcile the venue's order state.
  Execution::ReconcileIntentJob.perform_later(intent.id)
end
```

The discipline that keeps this tractable: **every request to the venue is a persisted, identified fact; every state change is an event from the venue applied through the machine.** Requests are ours to make; outcomes are the venue's to report.
