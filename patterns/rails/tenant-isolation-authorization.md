---
name: tenant-isolation-authorization
description: Enforce tenant membership and resource ownership as an explicit authorization boundary.
family: rails
---
# Tenant Isolation Authorization

## Problem
Multi-tenant applications accidentally permit cross-tenant reads or writes.

## Use when
Resources belong to an account, organization, workspace, or tenant.

## Structure
Resolve tenant from trusted actor/session context, scope resources to that tenant, then authorize additional action/resource rules.

## Implementation procedure
Never trust a tenant identifier supplied only by the client. Apply tenant scope consistently to nested queries, jobs, exports, caches, and APIs.

## Failure modes
Direct unscoped lookup, client-controlled tenant ID, unscoped background jobs, and shared cache keys.

## Testing
Cross-tenant read, update, delete, association, export, and job cases.

## Review checklist
Tenant identity is authoritative, explicit, and consistently enforced.

## Do not use when

Do not use this pattern when a simpler direct test or implementation is sufficient.

## Repository inspection

Inspect existing test conventions, fixtures, authorization helpers, and the relevant runtime or browser lifecycle.

## Related skills

rails-authorization, rails-hotwire, rails-test-engineering
