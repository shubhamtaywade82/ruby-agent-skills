# Side Effects and Recovery

## The sequencing question

Every transition with a side effect has one question to answer: does the effect commit with the state change, or does it run against the world outside the transaction? Mixing them casually produces the two classic corruptions:

1. **effect-succeeded / state-failed**: the payment was charged, the transaction rolled back, and no record says so — money moved for nothing.
2. **state-succeeded / effect-failed**: the record says `confirmed`, the confirmation email never went, and nobody knows.

The rule set:

- transactional effects (database writes, outbox rows) go **inside** the transition transaction;
- remote effects (payments, emails, provider calls, publishes) go **after the state commits**, driven by durable intent;
- every remote effect has a recovery decision written before it ships.

## Transactional effects

Inside `with_lock`, inside the transaction:

```ruby
def apply_event!(event, actor: nil)
  with_lock do
    # guard + authorize
    update!(state: target)
    state_audits.create!(...)
    Outbox::Message.create!(topic: "import.completed", payload: as_event_payload) # transactional publish
    AllocationAdjustment.create!(import: self, delta: -quota)                      # transactional side effect
  end
  after_commit_effects(event)
end
```

The outbox row publishes the event *after* commit via a dispatcher, so consumers never see events for rolled-back transitions. Publishing directly from inside the transaction (to Redis, a broker, Stripe) recreates effect-succeeded/state-failed with more steps.

## Remote effects and durable intent

Before any remote effect with material consequences, persist the intent; then execute; then record completion:

```ruby
# 1. In the transition transaction: record what must happen
intent = ExternalEffects.create!(
  kind: "payment_capture", subject: self, request_id: SecureRandom.uuid,
  params: { amount_cents: amount_cents }, status: "pending"
)

# 2. After commit: execute with the durable request identifier
PaymentGateway.capture(idempotency_key: intent.request_id, **intent.params)

# 3. Record the outcome (from the callback or the result)
intent.update!(status: "succeeded", provider_ref: response.id)
apply_event!("capture_succeeded", actor: :payment_gateway)
```

Two properties make this safe:

- **intent before effect**: the row exists before the call; a crash after the call is recoverable because the intent is visible with `status: pending`;
- **idempotent execution key**: the provider-side dedupe key (`request_id`/`client_order_id`) means a retry after an ambiguous outcome (timeout, crash after send) cannot double-charge — the provider answers with the original result.

Never generate a new idempotency key per retry: the key is the identity of *the intent*, and regenerating it is how systems double-pay.

## Failure recovery

Each partial-failure window has a defined path before shipping:

| Crash window | State | Recovery |
|---|---|---|
| before intent insert | clean | nothing happened; retry from the top |
| after intent insert, before effect | intent `pending` | executor job re-executes with the same key |
| after effect, before completion record | intent `pending`, provider succeeded | reconcile by querying the provider with the key; mark completed; apply the transition |
| after completion, before transition applied | effect recorded, state behind | completion worker applies the transition; duplicate application is idempotent (see the concurrency reference) |

The reconciliation worker is not optional infrastructure: it is the difference between "we think it worked" and "we know it worked":

```ruby
class PendingEffectReconciliationJob < ApplicationJob
  def perform
    ExternalEffects.pending.where("created_at < ?", 5.minutes.ago).find_each do |intent|
      outcome = PaymentGateway.lookup(intent.request_id)  # provider is the source of truth
      case outcome.status
      when :succeeded then intent.complete_and_apply!(outcome)
      when :failed     then intent.mark_failed!
      when :unknown    then intent.escalate!              # after the provider's own visibility window
      end
    end
  end
end
```

Escalation (`:unknown` after the provider's visibility horizon) pages a human; guessing is how duplicate payments happen during outages.

## Reconciliation

Reconciliation is the scheduled comparison of the machine against the world it mirrors (provider positions, ledger totals, inventory). It is a transition like any other — guarded, audited, and authorized to `system`:

```ruby
def reconcile!(authoritative_state:, evidence:)
  return :already_consistent if state == authoritative_state

  apply_event!("reconciled_to_#{authoritative_state}", actor: :reconciler)
  state_audits.create!(
    from_state: state, to_state: authoritative_state,
    event: "reconcile", actor: :reconciler, context: { evidence: evidence.slice("provider_ref", "as_of") }
  )
end
```

Rules:

- reconciliation transitions are in the table, guarded, and audited with evidence references — never raw `update_column` calls;
- reconciliation runs are idempotent: running twice against a consistent world changes nothing;
- divergences reconcile to the authoritative side (usually the external system), but `unknown` divergences alert instead of auto-correcting;
- every auto-correction has a rate limit: a reconciliation that "fixes" the same divergence daily is a bug in the machine being papered over.
