---
name: load-shedding
description: Protect critical system capacity by rejecting or degrading work before overload causes broad failure.
family: rails
---

# Load Shedding

## Problem

Incoming work can exceed safe capacity, causing queue growth, timeouts, retries, and cascading failure.

## Use when

Demand can exceed a known capacity boundary and some work can be rejected, delayed, or degraded.

## Do not use when

All requests are equally critical and there is no valid rejection/degradation contract.

## Repository inspection

Inspect capacity limits, traffic classes, priorities, rate limits, queue depth, latency, retry behavior, and business-critical operations.

## Implementation procedure

1. Identify the capacity boundary.
2. Define protected versus shed-able work.
3. Choose admission/rate/concurrency controls.
4. Define user-visible rejection/degradation.
5. Emit safe metrics for shed work.
6. Ensure durable business work is not silently lost.
7. Test overload and recovery.

## Failure modes

- shedding critical work
- accepting unlimited durable work then failing later
- hidden retry loop on rejected requests
- no operator visibility
- rejection violates tenant isolation/fairness

## Testing

Drive controlled overload and verify protected work stays within its contract while shed work receives the documented response.

## Review checklist

- [ ] capacity boundary explicit
- [ ] priority explicit
- [ ] rejection/degradation contract explicit
- [ ] no silent durable loss
- [ ] metrics visible
- [ ] overload test exists

## Related skills

- rails-reliability-engineering
- rails-performance
- ruby-concurrency
- rails-active-job
