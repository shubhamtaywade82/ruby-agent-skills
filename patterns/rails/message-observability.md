---
name: message-observability
description: Instrument message publication, delivery, processing, retry, dead-letter, and lag without exposing sensitive payloads.
family: rails
---

# Message Observability

## Problem

Queue-based failures are hard to diagnose when logs only show exceptions and do not connect producer, broker, consumer, and handler state.

## Use when

Operating asynchronous workflows or investigating message latency, retries, duplicates, or stuck consumers.

## Do not use when

The transport already exposes the full required lifecycle and application correlation without custom instrumentation.

## Repository inspection

Inspect request/correlation conventions, broker metrics, tracing, message IDs, log filtering, metrics backend, and existing Rails instrumentation.

## Implementation procedure

1. Propagate message, correlation, and causation IDs.
2. Record producer/consumer and message type/version.
3. Measure publish-to-consume and handler latency.
4. Record attempt/outcome state.
5. Track queue age/lag where transport data exists.
6. Keep logs structured and safe.
7. Correlate retries and replay with the original message identity.
8. Define alert thresholds tied to user/system impact.

## Failure modes

- new correlation ID at every hop
- logging full payloads
- metrics without message identity/context
- measuring only handler time and ignoring queue age
- retry storms hidden by aggregate success rate

## Testing

Verify propagation, filtering, retry correlation, and metric/instrumentation event shape.

## Review checklist

- [ ] IDs propagate
- [ ] queue age/lag visible
- [ ] retry/dead-letter state visible
- [ ] payloads are filtered
- [ ] replay remains traceable

## Related skills

- rails-event-driven-messaging
- rails-observability
- rails-security
- rails-testing

## Related patterns

- event-envelope
- request-observability
