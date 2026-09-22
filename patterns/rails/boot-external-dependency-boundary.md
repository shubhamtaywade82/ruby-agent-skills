---
name: boot-external-dependency-boundary
description: Boot External Dependency Boundary
family: rails
---
# Boot External Dependency Boundary

## Problem
External services accessed during boot make restarts fragile and slow.

## Use when
Boot requires an external dependency by explicit contract.

## Do not use when
The dependency can be resolved lazily.

## Repository inspection
Inspect startup dependencies, timeouts, readiness, restart behavior, and failure policy.

## Implementation procedure
Prefer lazy access; otherwise bound timeouts and define required/optional failure semantics.

## Failure modes
Restart storms, indefinite waits, false readiness.

## Testing
Test success, timeout, unavailable dependency, and health behavior.

## Review checklist
[ ] necessity [ ] timeout [ ] failure policy [ ] readiness

## Related skills
rails-initialization-configuration-engineering, rails-reliability-engineering, rails-production-runtime
