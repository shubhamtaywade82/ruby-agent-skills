---
name: authorized-resource-resolution
description: Authorized Resource Resolution Contract
family: security
---
# Authorized Resource Resolution Contract

## Problem
Broad lookup before authorization can reveal or mutate cross-tenant resources.

## Use when
Resources are tenant-owned or existence is sensitive.

## Do not use when
The resource is globally public and lookup itself has no security significance.

## Repository inspection
Inspect lookup queries, scopes, tenant foreign keys, policy scopes, and error mapping.

## Implementation procedure
Resolve through an authorized scope where practical before applying sensitive actions.

## Failure modes
IDOR, cross-tenant enumeration, inconsistent 404/403 behavior.

## Testing
Test cross-tenant IDs and absent resources through the real entry point.

## Review checklist
[ ] scoped lookup [ ] tenant filter [ ] denial mapping

## Related skills
rails-cross-boundary-authorization-security, rails-authorization, rails-active-record