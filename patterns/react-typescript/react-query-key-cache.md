---
name: react-query-key-cache
description: Make cache identity reflect the complete resource identity.
family: react-typescript
---

# React Query Key Cache

## Problem
A client-side cache stores parameterized or user-scoped resources.

## Use when
The data is not cached or identity is inherently singleton.

## Do not use when
Do not activate simply when The data is not cached or identity is inherently singleton. 

## Repository inspection
Inspect query parameters, tenant/account context, sorting, filters, and freshness rules.

## Implementation procedure
Build stable keys from every dimension that changes the resource and centralize key construction.

## Failure modes
One broad key for many resources, including mutable presentation state accidentally.

## Testing
Test distinct identities, cache hits, and invalidation.

## Review checklist
Could two different resources ever share this key?

## Related skills
react-data-fetching
