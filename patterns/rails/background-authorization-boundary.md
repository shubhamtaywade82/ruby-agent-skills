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

## Do not use when

Do not introduce this pattern when direct repository policy or scope logic is clearer and complete.

## Repository inspection

Inspect the existing authorization mechanism, callers, resource ownership, tenant scope, tests, and resolved framework versions.

## Implementation procedure

Define the boundary, adapt it to existing repository conventions, preserve failure semantics, and add regression tests.

## Review checklist

[ ] boundary is explicit
[ ] bypass callers considered
[ ] failure behavior preserved
[ ] tests cover rejection paths

## Related skills

rails-authorization, rails-security, rails-active-record, rails-test-engineering
