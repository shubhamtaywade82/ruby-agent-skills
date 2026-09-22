---
name: background-reauthorization-composition
description: Background Re-Authorization Composition
family: security
---
# Background Re-Authorization Composition

## Problem
Permission or ownership can change between enqueue and execution.

## Use when
A security-sensitive job is delayed or retried.

## Do not use when
The job performs a truly non-sensitive operation whose authorization is immutable and encoded by another invariant.

## Repository inspection
Inspect serialized arguments, membership state, tenant relationships, retries, and job timing.

## Implementation procedure
Serialize stable identities only; re-resolve current authorization/context when the job executes.

## Failure modes
Revoked membership still performs sensitive mutation, stale tenant access, bearer context in queue.

## Testing
Revoke access after enqueue and assert safe rejection at execution.

## Review checklist
[ ] current authorization checked [ ] stable identities [ ] revoke test

## Related skills
rails-cross-boundary-authorization-security, rails-active-job