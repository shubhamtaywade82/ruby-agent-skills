---
name: nested-serialization-boundary
description: Nested Serialization Boundary
family: rails
---
# Nested Serialization Boundary

## Problem
Nested associations can create oversized or recursively expanding payloads and hidden queries.

## Use when
Adding nested association serialization.

## Do not use when
A flat representation with no association traversal.

## Repository inspection
Inspect association cardinality, preload strategy, recursive relations, response size, and query count.

## Implementation procedure
Define bounded nesting, explicit fields, preloads, and collection limits where applicable.

## Failure modes
N+1 queries, recursive output, payload explosions, latency regressions.

## Testing
Use serializer/request tests with query-count and representative payload assertions.

## Review checklist
[ ] cardinality [ ] preload [ ] recursion [ ] payload size

## Related skills
rails-serialization-globalid-engineering, rails-performance