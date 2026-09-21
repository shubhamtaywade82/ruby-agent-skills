---
name: cache-warming-strategy
description: Precompute only high-value cache entries with bounded concurrency, source protection, and explicit refresh behavior.
family: rails
---

# Cache Warming Strategy

## Problem

Naive cache warming can move cold-start cost into deployment or startup and overload the source database or dependency.

## Use when

- a small set of known hot keys materially improves post-deploy latency;
- cold caches cause measured load spikes;
- precomputation is cheaper than repeated request-time work.

## Do not use when

- the key space is unbounded;
- warming has no measured benefit;
- lazy recomputation is cheaper and safe.

## Repository inspection

Inspect hot-key evidence, cache cardinality, source query/API cost, job queues, concurrency controls, deployment lifecycle, TTLs, and invalidation behavior.

## Implementation procedure

1. Identify the finite high-value key set.
2. Estimate source load.
3. Bound concurrency and batch size.
4. Make warm operations idempotent.
5. Define failure/retry behavior.
6. Align warming with expiration/invalidation.
7. Measure hit-rate and source-load impact.

## Failure modes

- warming unbounded keys;
- database/API overload;
- duplicate warming jobs;
- warm values immediately invalidated;
- retries causing load amplification;
- deployment blocked by non-critical warming.

## Testing

Test bounded batch execution, duplicate invocation, partial failure, and successful population of expected keys.

## Review checklist

- [ ] hot-key evidence
- [ ] finite scope
- [ ] bounded source load
- [ ] idempotent
- [ ] failure/retry policy
- [ ] measurable benefit

## Related skills

rails-caching, rails-active-job, rails-performance, rails-reliability-engineering
