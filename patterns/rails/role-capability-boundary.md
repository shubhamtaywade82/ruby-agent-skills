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
