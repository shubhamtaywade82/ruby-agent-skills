# Retry policy, dead-letter queues, poison messages, and replay

Reference for the `rails-event-driven-messaging` skill. Load it on demand when a change alters consumer retries, the dead-letter queue, poison-message handling, replay, or backfill. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Retry policy

Retry based on failure class:

Retryable:
- transient dependency outage;
- throttling;
- bounded connection/timeout failure;
- temporary broker/platform failure.

Usually permanent:
- schema incompatibility;
- invalid authentication;
- malformed payload;
- deterministic domain rejection;
- missing required reference that cannot become valid.

Every retry policy needs:

- maximum attempts;
- deadline or retention bound;
- backoff/jitter;
- queue isolation if necessary;
- terminal destination;
- replay authority.

Do not retry a poison message forever.

Coordinate retry budgets across broker, consumer framework, HTTP clients, and Active Job.

## Dead-letter queues and poison messages

A dead-letter mechanism is a containment and recovery boundary.

Capture safe metadata:

- original message ID;
- message type/schema;
- source topic/queue;
- first-seen time;
- attempts;
- failure class;
- correlation/causation ID;
- handler version.

Do not dump credentials or unnecessary sensitive payloads into dead-letter storage.

Define:

- who may inspect/replay;
- retention;
- remediation;
- replay safety;
- whether the original timestamp/identity is preserved.

Use the `dead-letter-replay` pattern.

## Replay and backfill

Replay is a production capability, not a test trick.

A replay system must define:

- selection criteria;
- immutable message identity;
- destination/consumer scope;
- rate limit;
- ordering;
- duplicate behavior;
- side-effect safety;
- operator authorization;
- audit trail;
- stop/resume semantics.

Prefer replaying from a durable source of truth or retained message log.

Do not blindly republish millions of events at production consumer speed without capacity control.

A replay should not accidentally trigger user-visible effects twice.
