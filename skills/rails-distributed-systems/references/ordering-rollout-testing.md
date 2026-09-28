# Ordering, replay, observability, rollout, and testing

Reference for the `rails-distributed-systems` skill. Load it on demand when a change depends on ordering or replay, or affects distributed telemetry, rollout compatibility, or tests. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Ordering and replay

Do not assume message order unless the transport guarantees it for the relevant key/partition.

Where order matters, define one of:

- sequence/version check;
- monotonic state transition;
- partition/key affinity;
- buffering of future events;
- reconciliation from source of truth.

Replay must be safe and observable.

Design event handlers so operators can replay from a durable event/message identity without creating uncontrolled duplicate side effects.

## Observability

Propagate a stable correlation/causation context across:

`request -> command -> outbox -> broker -> consumer -> dependency`

Record safe metadata:

- event/message ID;
- correlation/causation ID;
- producer/consumer;
- attempt/retry count;
- state transition;
- latency;
- queue age;
- outcome.

Do not log credentials, raw authorization headers, or unnecessary sensitive payloads.

Distributed debugging requires state-transition evidence, not only exception logs.

Compose with `rails-observability`.

## Rollout compatibility

For message-specific topology/schema/consumer concerns, compose with `rails-event-driven-messaging` rather than expanding this skill with broker-specific mechanics.

During rolling deployment:

- old and new consumers may coexist;
- old messages may arrive at new consumers;
- new messages may arrive at old consumers;
- retries may outlive the deployment that created them.

Therefore evolve message schemas additively first, tolerate unknown fields where appropriate, and delay destructive changes until old traffic/messages are drained.

For cross-service API changes use `rails-api-integration`.

## Testing

Every distributed boundary needs failure-path tests.

At minimum consider:

- duplicate delivery;
- producer failure around commit/publish;
- consumer failure before/after side effect;
- retry exhaustion;
- out-of-order events when relevant;
- replay;
- schema compatibility;
- partial saga completion;
- stale lock/lease behavior;
- eventual-consistency visibility;
- correlation/state-transition observability.

Use deterministic seams and fake transports/brokers where possible. Do not rely on random sleeps to "prove" distributed correctness.
