# Concurrency and Event Ordering

## Locking strategies

The wrong locking strategy either corrupts state (too weak) or collapses throughput (too strong). Choose by measured contention:

| Strategy | Correct when | Cost |
|---|---|---|
| none (guard only) | single writer exists and is provable | any second writer is silent corruption |
| optimistic (`lock_version`) | low contention, retry is cheap and safe | failed attempts need explicit retry policy |
| pessimistic row lock (`with_lock`) | concurrent attempts on the same record are expected (double-clicks, racing webhooks, workers) | lock held for the transaction's duration; keep it short |
| unique index on (record, event-identity) | duplicate event suppression | schema-level, covers the dedupe window you keep |

`with_lock` re-reads the row inside the transaction, so guards evaluate fresh state — this is what makes the check race-free, not the `raise`:

```ruby
def apply_event!(event, actor: nil)
  with_lock do
    target = TRANSITIONS.fetch(state, {})[event] or
      raise IllegalTransition, "#{state} + #{event} is not a legal transition"
    # state here is the freshly locked value
  end
end
```

Lock discipline:

- never hold the lock across a remote call (payment, broker, SMTP): sequence those outside the transaction (see the side-effects reference);
- lock the parent that owns the invariants when multiple records transition together, in a consistent order (by `id`) to avoid deadlocks;
- optimistic locking is not weaker — it is correct when the retry path is safe; it fails loudly where a stale write would have silently won.

## Concurrent transition attempts

The invariant to prove: of N simultaneous attempts to transition the same record, exactly the legal ones succeed and every loser sees an explicit outcome.

The failure modes this prevents:

1. **double transition**: two `cancel` attempts both read `pending`, both write `cancelled`, both fire the cancel side effect twice — a lost-update race, fixed by lock or optimistic check;
2. **interleaved transitions**: attempt A fires `fill` while attempt B fires `cancel`; without a lock both "succeed" and the record ends in whichever wrote last, with side effects of both — fixed by evaluating the guard under the same lock that writes;
3. **check-then-act across requests**: a controller checks `can_cancel?`, renders a button, and a job transitions before the user clicks — the action must re-guard at execution time, not trust the earlier check.

For state machines driven by requests plus background workers, the single guarded entry point is the whole defense: re-routes through `apply_event!` make stale checks harmless; direct assignments make every check theater.

## Duplicate and idempotent application

Every external event source (webhooks, brokers, feeds, retrying users) can deliver twice. Deduplicate on durable event identity, not on in-memory arrival:

```ruby
def apply_external_event!(envelope)
  ActiveRecord::Base.transaction do
    ProcessedEvent.create!(event_key: envelope.fetch("id"), consumer: self.class.name)
    apply_event!(envelope.fetch("event"), actor: envelope.fetch("source"))
  end
rescue ActiveRecord::RecordNotUnique
  # already applied in a committed transaction; this delivery is a duplicate
  :duplicate
end
```

The `event_key` unique index is the deduplication decision; the transaction couples it with the transition. Retention of processed keys defines the dedupe window: keep at least as long as the source can redeliver (broker retention, webhook retry policy).

Idempotency beyond dedupe — when the same logical intent arrives under *different* event identities (user double-submits, two systems send the same instruction) — needs a business idempotency key on the intent itself (for example `client_order_id` unique), which is the execution-safety boundary, not the machine's job alone.

## Out-of-order events

Delivery order is not application order. A `filled` callback can arrive after the order was already cancelled, or a `failed` event precedes the `started` event that is still in flight. Four policies, chosen per event and per state:

| Policy | Apply when | Shape |
|---|---|---|
| reject | the event is meaningless for this state and silence is a bug | raise/log with audit; e.g. `filled` on `cancelled` is an incident-worthy inconsistency |
| absorb | the outcome subsumes the event | `filled` arriving when already `filled` from a duplicate id — no-op with audit |
| buffer | the event is early but meaningful | park the event keyed by sequence/timestamp; apply when the predecessor arrives; bound the buffer |
| reconcile | the record is behind the truth | query the authoritative source (provider positions endpoint), correct state through a dedicated reconciliation transition with audit |

Sequence and timestamps make order detectable; without them, only reconciliation can close the gap:

```ruby
def apply_sequenced_event!(envelope)
  if envelope.fetch("seq") <= last_applied_seq
    return :absorbed          # duplicate or replay
  end
  if envelope.fetch("seq") > last_applied_seq + 1
    parked_events << envelope # bounded, keyed by seq; applied by the gap filler
    return :parked
  end
  apply_event!(envelope.fetch("event"), actor: envelope.fetch("source"))
  update!(last_applied_seq: envelope.fetch("seq"))
  drain_parked!
end
```

Buffering rules: bounded storage, alerting when a gap ages (the predecessor is never coming), and a drain path that applies parked events in sequence order. A buffer that only grows is an outage with extra steps.
