---
name: cross-cutting-ownership-contract
description: Cross-Cutting Ownership Contract
family: architecture
---
# Cross-Cutting Ownership Contract

## Problem
Cross-cutting concerns get duplicated when no subsystem owns their policy and integration contract.

## Use when
Introducing shared authentication, authorization, observability, reliability, configuration, or infrastructure behavior.

## Do not use when
A concern is purely local to one domain and has no cross-boundary behavior.

## Repository inspection
Inspect existing skills/components, middleware, controllers, jobs, event consumers, and configuration.

## Implementation procedure
Define one policy owner plus explicit adapters at framework boundaries; keep domain code focused on business responsibility.

## Failure modes
Parallel implementations, inconsistent semantics, missing enforcement at alternate entry points.

## Testing
Test representative boundaries and the shared policy.

## Review checklist
[ ] policy owner [ ] adapters [ ] alternate paths [ ] semantics consistent

## Related skills
rails-staff-principal-architecture, rails-cross-boundary-authorization-security