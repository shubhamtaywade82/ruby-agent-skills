---
name: circuit-breaker
description: Stop repeated calls to an unhealthy dependency after a justified failure threshold and probe recovery in a bounded way.
family: rails
---

# Circuit Breaker

## Problem

A failing dependency can consume request threads, connections, retries, and downstream capacity until the failure cascades through the application.

## Use when

A dependency has a meaningful failure domain and repeated calls should be stopped temporarily after evidence of unhealthy behavior.

## Do not use when

Timeouts, bounded retries, rate limits, or a simpler concurrency limit already provide sufficient containment.

## Repository inspection

Inspect dependency failure classes, latency/error metrics, client concurrency, timeout/retry policy, fallback behavior, and whether callers share the same failure domain.

## Implementation procedure

1. Define the dependency/failure domain.
2. Exclude failures that are not evidence of dependency health.
3. Choose an observation window and failure threshold from workload evidence.
4. Define open duration.
5. Define half-open probe count/concurrency.
6. Define fallback or fast-fail behavior.
7. Instrument state changes and rejected calls.
8. Test open, half-open, recovery, and repeated-failure paths.

## Failure modes

- breaker counts validation errors
- breaker opens too early from low-volume noise
- breaker opens too late to contain saturation
- all tenants share a breaker despite isolated failure domains
- half-open sends a recovery stampede
- breaker hides a permanently broken dependency

## Testing

Exercise closed->open, open fast-fail, half-open recovery, half-open failure, and reset behavior.

## Review checklist

- [ ] failure classification explicit
- [ ] threshold/window justified
- [ ] open duration bounded
- [ ] half-open concurrency bounded
- [ ] fallback explicit
- [ ] state transitions observable

## Related skills

- rails-reliability-engineering
- rails-api-integration
- rails-observability
- ruby-concurrency
