# Request performance, Puma concurrency, and connection-pool capacity

Reference for the `rails-performance` skill. Load it on demand when the bottleneck is request latency, Puma threads/workers, or database connection pool capacity. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Rails request performance

Decompose a slow request:

network
-> Rack/middleware
-> authentication/authorization
-> controller/application work
-> Active Record
-> serialization/rendering
-> external dependencies
-> response

Use existing Rails instrumentation and application telemetry to identify the dominant boundary.

Do not move work between layers without evidence that the move changes the bottleneck.

## Puma and web concurrency

When changing Puma workers or threads, reason about aggregate capacity:

workers × threads

Then compare that concurrency against:

- CPU;
- memory;
- Active Record connection pool;
- database capacity;
- external API limits;
- queueing behavior;
- lock/contention;
- container/platform limits.

Increasing threads while the database pool remains smaller can increase waiting rather than throughput.

Increasing workers may improve concurrency while exhausting memory.

Do not use generic worker/thread counts without workload evidence.

Use `patterns/rails/puma-capacity.md` for the capacity decision boundary.

## Connection-pool capacity

Database connections are shared capacity, not free concurrency.

Check:

- web worker/thread topology;
- job worker/thread topology;
- multiple Rails processes;
- multiple databases/roles/shards;
- pool size per process;
- database max connections;
- long-running transactions.

Reason about aggregate demand, not only one process.

When a pool timeout occurs, determine whether the root cause is:

- insufficient pool capacity;
- excessive application concurrency;
- long transactions;
- slow queries;
- connection leakage;
- downstream backpressure.

Do not increase pool size blindly. A larger pool can move the bottleneck into the database.

Use `patterns/rails/connection-pool-capacity.md`.
