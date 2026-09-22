---
name: engine-authorization-composition
description: Engine Authorization Composition Contract
family: security
---
# Engine Authorization Composition Contract

## Problem
Host application authorization can be assumed to cover engine routes when it does not.

## Use when
A mountable or isolated engine exposes protected resources.

## Do not use when
An engine has no protected routes or resources.

## Repository inspection
Inspect engine routes, controllers, policies, mount boundaries, host authentication, and namespace isolation.

## Implementation procedure
Define engine-side authorization explicitly and integrate host authentication/context deliberately.

## Failure modes
Engine route bypass, namespace confusion, host/engine policy divergence.

## Testing
Test mounted and direct engine routes with authorized and unauthorized contexts.

## Review checklist
[ ] engine routes protected [ ] host context explicit [ ] policy ownership

## Related skills
rails-cross-boundary-authorization-security, rails-engines-railties-engineering, rails-authorization