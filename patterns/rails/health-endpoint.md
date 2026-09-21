---
name: health-endpoint
description: Define Rails health and readiness semantics without coupling liveness to every dependency.
family: rails
---

# Health Endpoint

## Problem
Infrastructure needs deterministic health signals while application dependency failures may be transient or recoverable.

## Use when
Adding or reviewing Rails health, readiness, liveness, or dependency endpoints.

## Implementation procedure
1. Determine whether the endpoint is liveness, readiness, or dependency-specific.
2. Prefer Rails built-in health semantics when they match the requirement.
3. Add only necessary dependency checks.
4. Keep checks cheap and deterministic.
5. Do not expose internal failure details.
6. Test healthy and unhealthy states.

## Failure modes
- database/third-party outages causing unnecessary process restarts
- expensive health checks
- leaking internal exception details
- conflating liveness and readiness

## Testing
Assert status and response contract for each intended health state.

## Review checklist
- purpose is explicit
- dependency checks are justified
- response is deterministic
- no sensitive diagnostics leak

## Repository inspection

Inspect the repository's runtime/version, existing conventions, neighboring tests or implementation patterns, and the actual owning boundary before applying this pattern.

## Related skills

- rails-testing
- ruby-tdd-refactoring
- rails-architecture
