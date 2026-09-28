# Ownership, delivery semantics, outbox, inbox, retries, and consistency

Reference for the `rails-distributed-systems` skill. Load it on demand when a change crosses a service or process boundary with messages, retries, or eventual consistency. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Ownership and invariants

For every distributed workflow identify:

- system of record;
- authoritative writer;
- invariant owner;
- command owner;
- event producer;
- consumer responsibilities;
- recovery authority.

Do not maintain one business invariant in several services and hope eventual synchronization preserves it.

Persist the invariant where the authoritative writer can enforce it atomically.

## Delivery semantics

Do not assume exactly-once execution.

Make delivery explicit:

- at-most-once;
- at-least-once;
- effectively-once through durable deduplication/idempotency;
- ordered or unordered;
- immediate or eventual.

For at-least-once delivery, duplicate execution is a normal state, not an exceptional state.

Define acknowledgement semantics:

`receive -> persist/claim -> process -> acknowledge`

or the provider/broker-specific equivalent.

Never acknowledge durable work before the required state is safely recorded.

Use `patterns/rails/message-delivery-contract.md`.

## Outbox

When one database transaction must atomically produce application state and a message/event:

`business transaction -> durable outbox row -> asynchronous publisher -> broker -> consumer`

The outbox closes the "database committed but message was not published" gap.

An outbox does not provide exactly-once publication. Publishers may send the same logical event more than once.

Use stable event identity, publication state, retry/replay, and consumer idempotency.

Use `patterns/rails/outbox-publication.md`.

Compose with `transaction-boundary` and `transactional-job-enqueue` rather than duplicating their concerns.

## Inbox and deduplication

For a consumer that may receive duplicates:

`receive -> identify -> durably claim/deduplicate -> apply side effect -> record outcome`

Prefer a database-enforced uniqueness boundary for event/message identity when the consumer datastore owns the side effect.

Do not use an in-memory set or process-local mutex for cross-process deduplication.

Reuse `idempotent-job` when the final execution is an Active Job.

Use `patterns/rails/inbox-deduplication.md`.

## Retries and backpressure

A retry is a load multiplier.

Define:

- retryable failures;
- permanent failures;
- maximum attempts/deadline;
- backoff/jitter;
- queue isolation;
- dead-letter behavior;
- replay authority.

Do not let independently retrying layers multiply without a budget.

Bound concurrency against database pools, provider limits, broker capacity, and service throughput.

Use `rails-active-job`, `ruby-concurrency`, and `rails-performance` for the local capacity boundary.

## Consistency

Choose consistency deliberately:

- strong/read-after-write where user-visible correctness requires it;
- eventual consistency where independent services and asynchronous propagation are acceptable;
- explicit stale-read behavior where replicas/read models may lag.

Define what a caller observes during propagation:

`accepted`, `pending`, `committed`, `available`, or `failed`.

Never hide eventual consistency behind a synchronous-looking API that promises data the system cannot guarantee yet.

Use `patterns/rails/eventual-consistency.md`.
