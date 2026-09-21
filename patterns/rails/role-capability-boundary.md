---
name: role-capability-boundary
description: Separate role grouping from the actual capabilities required by an operation.
family: rails
---
# Role Capability Boundary

## Problem
Business permissions become scattered role-name conditionals.

## Use when
Roles map to multiple operations or capabilities.

## Structure
Represent capabilities explicitly; roles compose capabilities rather than becoming the only authorization primitive.

## Failure modes
Admin checks everywhere, role explosion, and hidden superuser bypass.

## Testing
Test capability boundaries and role-to-capability mapping.

## Review checklist
The policy expresses the operation, not merely a role label.

## Do not use when

Do not use this pattern when a simpler direct test or implementation is sufficient.

## Repository inspection

Inspect existing test conventions, fixtures, authorization helpers, and the relevant runtime or browser lifecycle.

## Implementation procedure

Define the contract, apply it at the correct boundary, and add focused deterministic regression coverage.

## Related skills

rails-authorization, rails-hotwire, rails-test-engineering
