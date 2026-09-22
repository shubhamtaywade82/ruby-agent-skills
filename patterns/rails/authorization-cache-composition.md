---
name: authorization-cache-composition
description: Authorization Cache Composition Contract
family: security
---
# Authorization Cache Composition Contract

## Problem
Cached permission decisions can survive role, membership, ownership, or resource-state changes.

## Use when
Authorization results are cached for performance.

## Do not use when
Policy evaluation is cheap enough or cache invalidation cannot be made trustworthy.

## Repository inspection
Inspect cache key, actor/tenant/resource identity, policy inputs, permission versioning, invalidation events, and TTL.

## Implementation procedure
Include all decision inputs in identity and define invalidation or bounded freshness semantics.

## Failure modes
Revoked access remains cached, cross-tenant cache collision, stale capability grants.

## Testing
Test revoke/change events and cache misses/hits across actors and tenants.

## Review checklist
[ ] key complete [ ] invalidation [ ] bounded TTL [ ] tenant isolation

## Related skills
rails-cross-boundary-authorization-security, rails-caching, rails-authorization