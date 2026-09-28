# Arguments, serialization, idempotency, and enqueue timing

Reference for the `rails-active-job` skill. Load it on demand when a change alters job arguments or serializers, duplicate-execution safety, or enqueueing from a transaction. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Arguments and serialization

Prefer small, stable arguments.

Use identifiers or supported serializable values when possible:

```ruby
ProcessInvoiceJob.perform_later(invoice.id)
```

Active Job supports common primitive/container types and Active Record objects through GlobalID. Passing a live record means deserialization can fail later if the record no longer exists. 

Do not pass:

- database connections
- request objects
- controllers
- open file handles
- transient service instances
- arbitrary complex runtime state
- secrets that should not be persisted in the queue payload

When passing an Active Record object is appropriate, understand that it is serialized by GlobalID and is looked up again when the job runs.

For custom types, inspect serializer support rather than inventing ad-hoc Marshal/JSON behavior.

## Idempotency

Assume a job can run more than once.

Make side effects safe against duplicate execution where retry/redelivery can repeat them.

Common techniques:

- database unique constraints
- idempotency keys
- state transitions guarded by predicates
- upserts
- compare-and-set updates
- external API idempotency keys
- durable execution records

Do not use an in-memory mutex as an idempotency mechanism across processes or hosts.

A job that sends an email, charges a payment, publishes an event, or calls an external API must explicitly answer:

```text
"What happens if perform runs twice?"
```

## Transactions and enqueue timing

Do not assume:

```text
record.save!
Job.perform_later(record.id)
```

is equivalent to "the job can safely run after the record is committed."

When enqueueing occurs inside a transaction, inspect the queue adapter and the repository's transaction semantics.

Rails supports `enqueue_after_transaction_commit` and documents it as a way to defer enqueueing until a surrounding transaction commits. It can be configured per job or on a common job base. 

Use this only when its semantics match the application's contract. Do not silently couple application correctness to a queue database sharing the application database.

A robust design should state whether the job requires:

- committed database state
- same-transaction durability
- independent queue storage
- eventual consistency
