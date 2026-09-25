---
name: postgres-query-before-cache
description: PostgreSQL Query Before Cache
family: stack-minimality
---
# PostgreSQL Query Before Cache

## Problem
Caching adds invalidation, freshness, memory, and failure semantics.

## Use when
A Rails/PostgreSQL query is slow or repeated and caching is proposed.

## Do not use when
Measured workload evidence proves caching is the correct boundary and freshness semantics are explicit.

## Repository inspection
Inspect the relevant application boundary, existing implementations, callers, dependencies, and runtime constraints before introducing a new layer.

## Implementation procedure
Inspect query count, query plan, cardinality, indexes, request/job frequency, and current cache policy before adding cache state.

## Failure modes
Cache-first optimization, stale data without a contract, stampedes, and authorization-cache leakage.

## Testing
Test query behavior and cache semantics separately.

## Review checklist
[ ] repository evidence checked [ ] smallest valid boundary chosen [ ] required guarantees preserved

## Related skills
rails-performance, rails-caching, rails-database-engineering, stack-minimality
