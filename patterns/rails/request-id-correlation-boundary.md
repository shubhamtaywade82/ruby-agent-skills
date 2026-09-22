---
name: request-id-correlation-boundary
description: Initialize and propagate one authoritative request correlation contract.
family: rails
---
# Request ID Correlation Boundary

## Problem
Parallel request-ID systems create fragmented logs and tracing and can allow untrusted identifiers to become trusted identity.

## Use when
Changing request IDs, correlation headers, or request-bound observability.

## Do not use when
The repository already has a complete mechanism and the change is unrelated.

## Repository inspection
Inspect Rails request ID behavior, log tags, tracing, downstream propagation, and existing observability tests.

## Implementation procedure
Reuse the authoritative ID, sanitize external input according to repository policy, attach context consistently, and preserve it through downstream work.

## Failure modes
Conflicting IDs, leaked sensitive headers, broken traces, and missing IDs on early failures.

## Testing
Test normal, rejected, and exceptional requests and assert log/trace context where the test harness supports it.

## Review checklist
[ ] single owner
[ ] external input treated appropriately
[ ] early paths covered
[ ] downstream propagation verified

## Related skills
rails-rack-middleware-engineering, rails-observability, rails-security-engineering
