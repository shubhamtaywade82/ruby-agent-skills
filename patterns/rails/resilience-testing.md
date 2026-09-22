---
name: resilience-testing
description: Test failure containment and recovery with bounded fault injection and explicit expected system behavior.
family: rails
---

# Resilience Testing

## Problem

Normal-path tests prove functionality but not whether the system remains safe under dependency, capacity, or process failures.

## Use when

Adding fault injection, recovery tests, game-day scenarios, or resilience regression coverage.

## Do not use when

A unit-level functional test is sufficient to prove the local behavior and no resilience boundary is involved.

## Repository inspection

Inspect failure boundaries, test framework, dependency seams, queue/job adapters, process controls, feature flags, and operational safety limits.

## Implementation procedure

1. State the fault.
2. Identify the protected user/system contract.
3. Define expected containment and degraded behavior.
4. Inject the smallest deterministic fault.
5. Verify no unsafe side effect/cascade.
6. Restore the dependency/capacity.
7. Verify recovery and convergence.
8. Record evidence and remaining assumptions.

## Failure modes

- fault injection without a stop condition
- test passes because the dependency was never actually used
- verifying only error response, not containment
- no recovery assertion
- destructive production experiment without authorization
- timing-sensitive flaky failure simulation

## Testing

Test dependency timeout, error, saturation, queue lag, process restart, and recovery scenarios as applicable. Prefer deterministic injected failures over arbitrary sleeps.

## Review checklist

- [ ] fault explicit
- [ ] containment contract explicit
- [ ] user behavior explicit
- [ ] recovery verified
- [ ] experiment bounded
- [ ] deterministic seam exists
- [ ] evidence recorded

## Related skills

- rails-reliability-engineering
- rails-test-engineering
- rails-observability
- rails-performance
