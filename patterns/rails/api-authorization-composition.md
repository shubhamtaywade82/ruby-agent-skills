---
name: api-authorization-composition
description: API Authorization Composition Contract
family: security
---
# API Authorization Composition Contract

## Problem
API authentication succeeds while resource or action authorization remains inconsistent.

## Use when
A protected API supports multiple resources, roles, or tenants.

## Do not use when
The endpoint is deliberately public and has no protected resource semantics.

## Repository inspection
Inspect authentication, route parameters, tenant resolution, policy scope, and response semantics.

## Implementation procedure
Compose authentication, context, authorized lookup, action authorization, validation, and side effect in that order.

## Failure modes
Authenticated-but-unauthorized access, IDOR, cross-tenant reads, inconsistent denial responses.

## Testing
Test valid, unauthorized, cross-tenant, revoked, and missing-resource requests.

## Review checklist
[ ] auth [ ] context [ ] authorized lookup [ ] action auth [ ] denial

## Related skills
rails-cross-boundary-authorization-security, rails-authorization