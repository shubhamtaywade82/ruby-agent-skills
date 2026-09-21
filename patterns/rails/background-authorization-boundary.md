---
name: background-authorization-boundary
description: Re-authorize security-sensitive work when a background job executes after the request has ended.
family: rails
---
# Background Authorization Boundary

## Problem
Authorization state changes between enqueue and execution.

## Use when
Jobs mutate or expose tenant/user-owned resources.

## Structure
Serialize stable identifiers only; re-resolve actor, tenant, membership, and resource state at execution time.

## Failure modes
Serialized bearer token, enqueue-time authorization trusted forever, and unscoped resource lookup.

## Testing
Revoke membership after enqueue and assert execution fails safely.
