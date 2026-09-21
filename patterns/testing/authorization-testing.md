---
name: authorization-testing
description: Test authorization decisions and application boundaries with deterministic allow/deny contracts.
family: testing
---
# Authorization Testing

## Problem
Authorization tests cover only happy-path access.

## Use when
Adding or changing a policy, scope, tenant rule, or protected endpoint.

## Structure
Use focused policy tests plus request/system tests for wiring. Add regression cases for every discovered bypass.

## Required cases
Allow/deny by action, cross-tenant isolation, collection scope, ownership, role/capability, resource state, direct service invocation, background re-authorization, API/realtime boundaries, stale membership, cache invalidation, and IDOR regression.

## Review checklist
A green suite must demonstrate that unauthorized paths are rejected, not merely that authorized paths work.

## Do not use when

Do not use this pattern when a simpler direct test or implementation is sufficient.

## Repository inspection

Inspect existing test conventions, fixtures, authorization helpers, and the relevant runtime or browser lifecycle.

## Implementation procedure

Define the contract, apply it at the correct boundary, and add focused deterministic regression coverage.

## Failure modes

Happy-path-only coverage, hidden bypass paths, and tests coupled to incidental implementation details.

## Testing

Test both expected success and rejection/failure behavior at the narrowest deterministic boundary.

## Related skills

rails-authorization, rails-hotwire, rails-test-engineering
