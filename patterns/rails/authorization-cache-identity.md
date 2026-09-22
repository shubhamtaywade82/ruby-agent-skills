---
name: authorization-cache-identity
description: Key authorization caches by every input that can change a permission decision.
family: rails
---
# Authorization Cache Identity

## Problem
A cached allow/deny survives a permission or tenant change.

## Structure
Include actor, tenant, action, resource/version, and relevant permission/policy version in the cache identity.

## Implementation procedure
Document invalidation on membership, role, ownership, or policy changes. Prefer short-lived caching when invalidation is difficult.

## Failure modes
Actor-only keys, resource ID without tenant, and stale allow after revocation.

## Testing
Change a permission and assert the next decision reflects the new state.

## Use when

Use this pattern when the named security boundary is part of the requested change.

## Do not use when

Do not introduce this pattern when a simpler repository-consistent boundary already proves the required contract.

## Repository inspection

Inspect the existing authorization mechanism, entry points, resource ownership, tenant scope, tests, and versioned dependencies.

## Review checklist

[ ] authoritative mechanism preserved
[ ] bypass paths reviewed
[ ] tenant/resource scope explicit
[ ] rejection behavior tested

## Related skills

rails-authorization, rails-authentication, rails-security, rails-test-engineering
