# Active Record query performance, N+1, read paths, pagination, and query plans

Reference for the `rails-performance` skill. Load it on demand when the bottleneck is query count, N+1 access, read-path design, data volume, or indexes and query plans. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Active Record query performance

When diagnosing a slow Rails query, inspect:

1. query count;
2. query duration;
3. SQL shape;
4. predicates and selectivity;
5. joins;
6. eager loading/preloading;
7. selected columns;
8. object materialization;
9. ordering/grouping;
10. pagination strategy;
11. indexes and cardinality;
12. lock/transaction scope;
13. connection-pool pressure.

Prefer query-plan evidence over intuition.

Use `EXPLAIN` or the database's plan tooling when query execution strategy is the question.

Do not solve every query problem with `includes`. Determine whether the real issue is N+1 access, excessive row volume, object materialization, missing indexes, poor predicates, pagination, or contention.

## Query-count regression gate

Before changing code to fix an N+1 or reduce query count, write a test that pins the target count. Run it on the unchanged code and record the observed count it fails with. The fix is done when that test passes; a fix without a test that failed first is unverified.

Use the assertion the suite already has:
- Minitest on Rails 7.2+: `assert_queries_count(3) { get orders_path }`. Use `assert_no_queries { ... }` for paths that must not query. These ignore schema queries unless `include_schema: true` is passed.
- RSpec with `db-query-matchers` already in the bundle: `expect { get orders_path }.to make_database_queries(count: 3)`.
- Otherwise: count `sql.active_record` events with `ActiveSupport::Notifications.subscribed`, excluding `SCHEMA` and cached queries. Do not add a gem for one test.

Size the data so the N+1 would show: at least two parents, each with associated rows. Then confirm the plan of the rewritten query with `EXPLAIN` / `EXPLAIN ANALYZE` on representative non-production data. `EXPLAIN ANALYZE` executes the query, so never run it casually against production.

## N+1 detection

Treat N+1 as a query-shape defect.

Typical form:

request
-> load parent records
-> iterate parents
-> lazy-load association for each parent

Preferred fixes depend on the contract:

- `preload` when independent association queries are appropriate;
- `eager_load` when a joined result is required;
- `includes` when Rails should choose based on usage and query shape;
- a direct join/select when only scalar fields are needed;
- a query object when read logic has become complex.

Verify query count or SQL shape rather than merely adding an eager-loading call.

Do not eager-load large associations that are not actually used. Memory and row explosion can be worse than the original query pattern.

## Query-object and read-path design

Use a query object or explicit read boundary when:

- query composition is complex;
- the same read path is reused;
- the query has domain-specific semantics;
- the controller/model would otherwise own a large read operation.

Do not create a query object for a simple one-off relation that is clearer in place.

Keep performance fixes at the boundary owning the cost.

## Pagination and data volume

For large datasets inspect:

- page size;
- OFFSET cost;
- stable ordering;
- keyset/cursor pagination suitability;
- selected columns;
- count queries;
- serialization/rendering cost;
- per-row association access.

Never assume pagination makes a query cheap. Measure the actual generated SQL and returned rows.

## Indexes and query plans

An index is justified by a target query shape and database evidence.

Before adding an index:

1. identify the query;
2. inspect predicate selectivity;
3. inspect existing indexes;
4. inspect the execution plan;
5. consider write/storage cost;
6. consider live-deployment locking/build behavior;
7. verify the new plan after the change.

Use `patterns/rails/production-index.md` for production index changes.

Do not add indexes because a column "looks searchable."
