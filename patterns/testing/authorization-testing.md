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
