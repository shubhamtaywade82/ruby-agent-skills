---
name: controller-service-authorization-composition
description: Controller and Service Authorization Composition
family: security
---
# Controller and Service Authorization Composition

## Problem
A controller may authorize correctly while direct service callers bypass the same rule.

## Use when
A service can be called by jobs, tasks, events, or multiple controllers.

## Do not use when
A service is purely internal and has an enforced single trusted caller contract.

## Repository inspection
Inspect service callers, policy mechanism, command interfaces, and tests.

## Implementation procedure
Authorize the application operation at the service boundary or require an explicit authorized capability/context.

## Failure modes
Direct bypass, ambient current user, duplicate conflicting checks.

## Testing
Invoke the service directly and through each public caller.

## Review checklist
[ ] direct call secured [ ] capability explicit [ ] parity tested

## Related skills
rails-cross-boundary-authorization-security, rails-authorization