# Sagas, distributed locks, and multi-region deployments

Reference for the `rails-distributed-systems` skill. Load it on demand when a change coordinates multi-step workflows, introduces a distributed lock or lease, or spans regions. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Sagas

A saga coordinates multiple local transactions without pretending they are one distributed transaction.

Use when a business workflow must span independently owned transaction boundaries.

For each step define:

- forward action;
- success state;
- timeout;
- retry behavior;
- compensation;
- compensation failure/recovery;
- workflow state;
- operator/replay path.

Prefer orchestration when one component must own workflow state and sequencing. Prefer choreography only when independently reacting services keep coupling manageable and observability remains sufficient.

Do not use a saga when one local transaction can enforce the invariant.

Use `patterns/rails/saga-orchestration.md`.

## Distributed locks

Before adding a distributed lock ask whether:

- a unique constraint;
- compare-and-set update;
- row lock;
- queue partition/key;
- concurrency-controlled job;
- single authoritative writer

already solves the invariant.

If a distributed lock is required, define:

- lease duration;
- ownership identity;
- renewal;
- expiration behavior;
- failure after lease loss;
- fencing/token semantics where stale holders are dangerous;
- contention/backoff;
- monitoring.

A lock without fencing can still permit stale owners after pauses or network partitions.

Never treat a lock as proof that a side effect happened exactly once.

Use `patterns/rails/distributed-lock.md`.

## Multi-region deployments

Do not adopt multi-region topology without a concrete residency, latency, or regional-availability requirement. A single region with edge caching satisfies most latency goals.

Before designing for multiple regions, define:

- the requirement single-region cannot satisfy;
- the authoritative write region and replication direction/lag budget;
- the ownership model: single write region, region-partitioned data, or independent stacks with reconciliation;
- data residency boundaries enforced at the storage layer, not by convention;
- region routing and user pinning, and their behavior during failover;
- failover: promotion, fencing against the old primary, RPO/RTO, and conflict handling;
- region-local dependencies (jobs, cache, blob storage) and their failover targets.

Keep synchronous cross-region calls out of user request paths.

Use `patterns/rails/multi-region-data-boundary.md`.
