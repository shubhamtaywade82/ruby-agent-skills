# Active Record and Database Review

Use when code touches models, associations, validations, scopes, callbacks, queries, migrations, indexes, constraints, bulk operations, transaction boundaries, or concurrent persistence. Compose with rails-active-record, rails-associations, rails-validations, and rails-database-engineering.

## Validation and durable invariants

A Rails validation is application-level feedback. It may not protect against concurrent writers or write paths that bypass validations. For a critical invariant, inspect the authoritative database schema and all write paths.

```ruby
validates :email, uniqueness: true
```

This code alone does not prove uniqueness is enforced under concurrent inserts. Inspect the schema/migration for the intended unique constraint or index, including partial/compound uniqueness requirements. Confirm existing data, backfill, and deployment constraints before prescribing a migration.

## Callbacks and side effects

Understand callback order, transactional callbacks, validation contexts, and callback-bypassing APIs. An external side effect before commit can survive a database rollback. Bulk updates/deletes/imports may skip validations and callbacks. Trace every relied-upon audit, enqueue, and notification behavior before making a finding.

## Transactions and concurrency

Ask:
- Which operations must be atomic together?
- Can concurrent requests violate a state or uniqueness invariant?
- Does a lock cover the complete read/check/write sequence?
- Can lock ordering create deadlocks?
- What is the retry behavior for serialization/deadlock failures?
- Are external side effects incorrectly assumed to roll back with the database?

## Queries and associations

Inspect Relation laziness, accidental materialization, N+1 behavior, missing pagination, ordering assumptions, aggregates, scopes, default scopes, association cardinality, dependent lifecycle, and whether tenant authorization is incorrectly delegated to a default scope.

Performance claims should be grounded in query shape, representative workload, query plans, or measurements when material. Avoid speculative index recommendations without query or constraint evidence.

## Migrations and deployment

Review migration reversibility and data effects, index creation strategy, backfill batching/checkpointing, concurrent index requirements, foreign/check constraints, long locks, and compatibility with old and new application versions during rolling deployment. Consider deploy ordering and rollback.

## Reportable evidence

Do not claim a database race only because a validation exists. Show the concurrent sequence or bypassing write path. Do not claim callbacks are skipped without identifying the actual operation. Tie recommendations to the application's Rails version, schema, and deployment conventions.
