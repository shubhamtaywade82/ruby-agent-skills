---
name: middleware-rate-limit-boundary
description: Apply rate limiting at the correct infrastructure boundary with explicit capacity and consistency semantics.
family: rails
---
# Middleware Rate Limit Boundary

## Problem
An in-process limiter can be bypassed across workers or instances and can become an unbounded memory leak.

## Use when
Rate limiting is transport/request based and belongs before expensive downstream work.

## Do not use when
The limit depends on resource ownership or a business rule better enforced after authentication/authorization.

## Repository inspection
Inspect deployment topology, existing rate-limit infrastructure, identity source, trusted proxy behavior, store availability, and failure policy.

## Implementation procedure
Define keying, window/token semantics, store ownership, response contract, fail-open/closed behavior, and cleanup.

## Failure modes
Per-process bypass, spoofed client identity, store outage amplification, and unbounded local state.

## Testing
Test limits, reset behavior, concurrency, multi-process assumptions where possible, and store failure behavior.

## Review checklist
[ ] key trusted
[ ] topology accounted for
[ ] bounded state
[ ] failure policy explicit

## Related skills
rails-rack-middleware-engineering, rails-reliability-engineering, rails-security-engineering
