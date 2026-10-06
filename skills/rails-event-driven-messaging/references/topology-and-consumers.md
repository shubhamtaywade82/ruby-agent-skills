# Topology, partitioning, consumer groups, handlers, and acknowledgement

Reference for the `rails-event-driven-messaging` skill. Load it on demand when a change alters topics/queues/routing keys/partitions, consumer groups, handler boundaries, or acknowledgement. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Topic, queue, routing-key, and partition design

Choose topology around ownership and workload.

Define:

- producer ownership;
- intended consumers;
- fan-out semantics;
- retention;
- replay requirements;
- partition/routing key;
- maximum acceptable lag;
- message size expectations;
- ordering scope.

A partition/routing key should preserve ordering for the entity whose transitions require order without creating a single global bottleneck unnecessarily.

Do not partition on a high-cardinality field merely because it distributes load; verify the ordering requirement and hot-key risk first.

Use the `consumer-group-partitioning` pattern.

## Consumer groups and parallelism

A consumer group distributes work among active consumers according to transport semantics.

Before increasing consumer count, evaluate:

- partition/shard count;
- downstream concurrency;
- database connection pool;
- external API rate limits;
- CPU/memory;
- message processing latency;
- ordering constraints;
- rebalancing behavior;
- shutdown/recovery semantics.

A consumer group does not make the handler idempotent.

Do not scale consumers beyond the transport's parallelism or downstream capacity.

## Handler boundary

Keep the message adapter responsible for:

- decode;
- schema validation;
- authentication/integrity when applicable;
- envelope validation;
- correlation extraction;
- deduplication/claim;
- dispatch to application/domain behavior;
- acknowledgement outcome mapping.

Do not expose broker-specific payload objects throughout the domain.

The handler should be safe to invoke from replay and should answer:

`What happens if this message is delivered twice?`

## Acknowledgement

Acknowledgement is part of correctness.

Define when a message becomes eligible for acknowledgement:

- after durable claim;
- after durable state transition;
- after external side effect with idempotency;
- after complete handler success.

Do not acknowledge merely because the message parsed successfully.

Do not acknowledge a poison message indefinitely without routing it to an explicit terminal/review path.

Use the transport-specific acknowledgement contract; never invent "ack after enqueue" semantics without verifying what durability that represents.
