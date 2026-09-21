---
name: api-authorization-boundary
description: Enforce authorization explicitly at API resource boundaries.
family: rails
---
# API Authorization Boundary

## Problem
An API authenticates a caller but does not consistently authorize resource actions.

## Structure
Authenticate, establish tenant/context, resolve authorized resource scope, authorize action, then mutate/read.

## Failure modes
Bearer token treated as permission, IDOR through direct lookup, inconsistent status/error semantics, and frontend-only permission checks.

## Testing
Exercise valid, invalid, cross-tenant, and stale-permission requests.
