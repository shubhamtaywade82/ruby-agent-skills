---
name: action-cable-failure-boundary
description: Define graceful degradation when Action Cable or its pub/sub adapter is unavailable.
family: rails
---

# Action Cable Failure Boundary

## Problem

Realtime delivery failures should not accidentally become database or request-path failures when live updates are optional.

## Use when

- adding broadcasts around core business operations;
- handling Redis or cable outages;
- designing realtime fallback.

## Do not use when

- realtime acknowledgement is explicitly part of the business transaction contract.

## Repository inspection

Inspect transaction ownership, broadcast producer, Redis adapter, client fallback, durable notification path, and incident/recovery conventions.

## Implementation procedure

1. Classify realtime as required or optional.
2. Define fallback.
3. Keep authoritative state independent.
4. Bound broadcast retry behavior.
5. Surface degraded mode to clients where needed.
6. Instrument failures.

## Failure modes

- broadcast failure rolls back unrelated business state;
- hidden retry loops;
- no client reconciliation;
- optional delivery treated as guaranteed.

## Testing

Test adapter failure with successful domain transaction and verify fallback/reconciliation.

## Review checklist

- [ ] business criticality
- [ ] fallback
- [ ] transaction independence
- [ ] retry budget
- [ ] telemetry
- [ ] tests

## Related skills

rails-action-cable, rails-reliability-engineering, rails-distributed-systems, rails-event-driven-messaging
