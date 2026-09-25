---
name: postgres-index-from-query-evidence
description: PostgreSQL Index From Query Evidence
family: stack-minimality
---
# PostgreSQL Index From Query Evidence

## Problem
Indexes add storage, write, maintenance, and planner costs.

## Use when
Optimizing a PostgreSQL query, endpoint, report, or job.

## Do not use when
A constraint already requires an index or the required index is already present.

## Repository inspection
Inspect the relevant application boundary, existing implementations, callers, dependencies, and runtime constraints before introducing a new layer.

## Implementation procedure
Inspect query shape, cardinality, existing indexes, and representative plans. Add the smallest index that serves the actual predicate/order/join shape.

## Failure modes
Indexing by column intuition, duplicate indexes, and unmeasured performance claims.

## Testing
Use real EXPLAIN ANALYZE and migration verification.

## Review checklist
[ ] repository evidence checked [ ] smallest valid boundary chosen [ ] required guarantees preserved

## Related skills
rails-database-engineering, rails-performance, stack-minimality-evidence, stack-minimality
