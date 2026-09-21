---
name: slo-error-budget
description: Define measurable service objectives and use their error budget to guide operational and engineering decisions.
family: rails
---

# SLO & Error Budget

## Problem

Teams track many metrics but do not define which reliability outcomes matter to users or how reliability failures change engineering decisions.

## Use when

Defining service reliability objectives, alerting, release gates, or incident priorities.

## Do not use when

The work is a single local bug with no service-level reliability contract.

## Repository inspection

Inspect user journeys, existing telemetry, incident history, business criticality, reporting windows, deployment cadence, and current alerting.

## Implementation procedure

1. Identify the critical user journey.
2. Choose an SLI that measures user-visible success, latency, freshness, or correctness.
3. Define the measurement window and target.
4. Derive the allowed error budget.
5. Define burn-rate or budget-consumption alerts.
6. Define engineering actions when budget is exhausted or rapidly consumed.
7. Revisit the target from observed evidence.

## Failure modes

- vanity infrastructure metric used as the SLI
- arbitrary high target
- alerting on every error
- budget exists but has no operational consequence
- changing the target to hide failures

## Testing

Test metric calculation against representative success/failure and latency data. Verify alert thresholds and budget actions.

## Review checklist

- [ ] user journey explicit
- [ ] SLI user-visible
- [ ] target/window explicit
- [ ] budget derived
- [ ] alert action explicit
- [ ] target evidence-based

## Related skills

- rails-reliability-engineering
- rails-observability
- rails-performance
