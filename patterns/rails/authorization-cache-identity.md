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
