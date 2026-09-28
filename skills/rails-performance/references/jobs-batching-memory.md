# Background-job performance, batching, memory, and regression testing

Reference for the `rails-performance` skill. Load it on demand when the bottleneck is job throughput, batch size, memory or allocations, or a change needs performance regression tests. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Background-job performance

For Active Job/background workers inspect:

- batch size;
- serialization;
- query pattern;
- N+1 inside jobs;
- retry amplification;
- job concurrency;
- database pool usage;
- external API latency/rate limits;
- memory growth;
- idempotency;
- queue depth and wait time.

A faster individual job can still reduce system throughput if it increases downstream contention.

When increasing job concurrency, coordinate with `rails-active-job`, `ruby-concurrency`, and `rails-database-engineering`.

## Batching

Use batching for large data processing when memory or transaction size is the limiting factor.

Choose batch size based on evidence:

- query latency;
- memory;
- lock duration;
- database log/replication pressure;
- downstream rate limits.

Avoid giant transactions for unbounded datasets.

Avoid tiny batches that create excessive query overhead.

## Memory and allocations

For Rails-specific memory problems inspect:

- Active Record object materialization;
- oversized result sets;
- serializers/renderers;
- cached objects;
- retained references;
- job batch size;
- worker lifecycle;
- GC pressure.

Use `ruby-performance` for allocation and GC measurement.

Do not replace clear Rails code with mutable low-level code without measured benefit.

## Performance regression testing

Prefer structural performance contracts when wall-clock timing is unstable:

- query count;
- SQL shape;
- allocation bounds;
- number of external calls;
- batching behavior;
- cache-key behavior;
- algorithmic complexity.

For timing benchmarks, define a representative workload and a threshold with enough warmup/iterations to avoid machine-noise-driven failures.

Do not create CI tests that are so tight they fail because the runner is noisy.
