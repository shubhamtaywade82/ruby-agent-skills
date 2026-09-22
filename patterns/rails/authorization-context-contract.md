---
name: authorization-context-contract
description: Authorization Context Contract
family: security
---
# Authorization Context Contract

## Problem
Security decisions drift when actor, tenant, resource state, or execution context is implicit.

## Use when
A protected operation is invoked across multiple layers.

## Do not use when
A simple policy has one explicit caller and no contextual boundary changes.

## Repository inspection
Inspect policy inputs, current_user/current_actor usage, tenant context, service identity, and callers.

## Implementation procedure
Define an explicit authorization context containing only required security facts and pass it deliberately.

## Failure modes
Ambient context, missing tenant, stale actor state, and caller-dependent policy behavior.

## Testing
Test equivalent decisions with explicit contexts.

## Review checklist
[ ] actor explicit [ ] tenant/context explicit [ ] no hidden security state

## Related skills
rails-cross-boundary-authorization-security, rails-authorization