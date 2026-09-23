---
name: react-server-state-boundary
description: Keep remote resource state distinct from local UI state.
family: react-typescript
---

# React Server State Boundary

## Problem
The UI consumes API-backed resources with freshness, loading, and retry semantics.

## Use when
The state is purely local and has no remote lifecycle.

## Do not use when
Do not activate simply when The state is purely local and has no remote lifecycle. 

## Repository inspection
Inspect existing query/cache infrastructure, authentication, and resource identity.

## Implementation procedure
Use repository-standard server-state tooling, define freshness, and expose loading/error/success states deliberately.

## Failure modes
Putting server state in UI context, duplicate fetch logic, and stale data treated as current truth.

## Testing
Test cache hit, refetch, failure, invalidation, and auth context.

## Review checklist
Where is server-state ownership defined?

## Related skills
react-data-fetching,react-architecture
