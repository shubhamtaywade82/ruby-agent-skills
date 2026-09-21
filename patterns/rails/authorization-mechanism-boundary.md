---
name: authorization-mechanism-boundary
description: Reuse the repository's authoritative authorization mechanism without creating parallel policy paths.
family: rails
---
# Authorization Mechanism Boundary

## Problem
Authorization logic is duplicated across controllers, models, services, or libraries.

## Use when
The repository already has Pundit, CanCanCan, custom policies, roles/permissions, or another established mechanism.

## Do not use when
No coherent authorization mechanism exists; first define the smallest repository-consistent boundary.

## Repository inspection
Find policy/ability classes, base policies, authorization helpers, controller hooks, and tests.

## Structure
Keep one authoritative decision path and explicit adapters only at framework boundaries.

## Implementation procedure
Identify the mechanism, map entry points to it, avoid parallel checks, preserve denial semantics, and add regression tests.

## Failure modes
Duplicate policy engines, controller-only checks, inconsistent denial behavior, and library-version mismatch.

## Testing
Verify representative allow/deny cases through policy and request boundaries.

## Review checklist
One source of truth, explicit integration boundary, no bypass path.
