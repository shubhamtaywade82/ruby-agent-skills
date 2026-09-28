# Parallel tests, test performance, CI, and eager loading

Reference for the `rails-test-engineering` skill. Load it on demand when a change enables or debugs parallel tests, speeds up the suite, changes CI test strategy, or adds an eager-loading test. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Parallel test safety
Rails supports parallel testing with processes by default and also supports threads. The number of workers can be configured directly or via PARALLEL_WORKERS. Rails creates separate test databases for process workers.

Before enabling or increasing parallelism, audit:
- global mutable state;
- shared filesystem paths;
- fixed ports;
- external test doubles;
- cache state;
- singleton registries;
- sequence assumptions;
- database connection capacity;
- non-transactional tests.

Never make a flaky suite green by reducing parallelism without identifying the isolation defect.

When thread parallelism is used, inspect thread safety and database connection behavior. Use ruby-concurrency for the underlying concurrency analysis.

## Parallel database tests
Parallel test workers require database capacity and isolation.

Check:

test workers
×
connections per worker
≤
test database/server capacity

When multiple databases/shards/roles are configured, verify worker setup for each one.

Rails exposes parallelize_setup and parallelize_teardown hooks for process-based parallel test setup when needed.

## Test parallelization threshold
Parallelization has startup/database/fixture overhead.

Do not force parallel execution for tiny suites. Rails itself has a configurable threshold and currently avoids parallelizing suites below the default threshold.

Benchmark before changing threshold values.

## Test performance
Treat test runtime as engineering capacity.

Measure separately:
- test boot time;
- database setup time;
- fixture/factory cost;
- individual slow tests;
- system test cost;
- parallel coordination overhead.

Optimize only after measurement.

Common high-value changes include:
- narrowing a broad integration test;
- reducing factory graph depth;
- removing unnecessary eager helper loading;
- using targeted fixtures;
- parallelizing only sufficiently large suites;
- avoiding real external I/O;
- reducing redundant system tests.

Rails warns that eagerly requiring all test helpers increases boot time compared with requiring only needed helpers.

Do not optimize by weakening assertions or removing coverage without an explicit contract decision.

## CI strategy
CI should prove more than local unit tests.

A robust pipeline typically separates:

fast focused tests
-> full application tests
-> system/browser tests
-> eager-load verification
-> lint/security/static checks

Rails documents that bin/rails test does not run system tests by default; bin/rails test:system or bin/rails test:all can include them. Rails also documents eager loading during CI as a way to detect load failures before production.

Use repository-specific CI commands rather than assuming these exact commands apply.

## Eager-loading test
When Rails code is sensitive to autoloading structure, CI should exercise eager loading where practical.

Rails documents enabling eager loading in CI and also provides an explicit Rails.application.eager_load! test pattern.

Pair this with rails-zeitwerk rather than duplicating loader rules in tests.
