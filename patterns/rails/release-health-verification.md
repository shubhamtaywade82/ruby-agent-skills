---
name: release-health-verification
description: Verify release success using user-impact, dependency, workload, readiness, and correctness signals over a defined observation window.
family: rails
---

# Release Health Verification

## Problem
A deployment can be technically healthy while user outcomes or background workloads remain degraded.

## Use when
- completing a production release;
- implementing automated release checks;
- investigating post-deploy regressions.

## Do not use when
- defining the SLO itself; use rails-reliability-engineering.

## Repository inspection
Inspect release health endpoints, SLIs/SLOs, dependency telemetry, queue/backlog signals, error reporting, and incident thresholds.

## Implementation procedure
1. Record baseline. 2. Deploy controlled exposure. 3. Verify process/readiness. 4. Compare user-impact metrics. 5. Verify dependency and backlog behavior. 6. Check correctness/data integrity signals. 7. Complete the observation window and record evidence.

## Failure modes
- using /up alone;
- no baseline;
- too-short observation window;
- ignoring worker/backlog behavior;
- ignoring correctness.

## Testing
Test release health gates with synthetic regressions and deterministic pass/fail windows.

## Review checklist
- [ ] baseline; - [ ] process/readiness; - [ ] user SLI; - [ ] dependency; - [ ] queue; - [ ] correctness; - [ ] window.

## Related skills
rails-release-engineering, rails-observability, rails-reliability-engineering, rails-incident-engineering