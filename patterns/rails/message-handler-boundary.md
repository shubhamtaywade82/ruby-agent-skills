---
name: message-handler-boundary
description: Isolate transport decoding, validation, deduplication, dispatch, and acknowledgement from domain behavior.
family: rails
---

# Message Handler Boundary

## Problem

Broker-specific payloads and acknowledgement logic leak throughout application/domain code.

## Use when

Implementing or refactoring consumers so transport semantics need isolation from business behavior.

## Do not use when

The repository has a framework-owned handler abstraction that already cleanly enforces the same boundary.

## Repository inspection

Inspect consumer adapter, serializer, validation, idempotency/inbox storage, domain services, broker client, and acknowledgement lifecycle.

## Implementation procedure

1. Decode transport input at the edge.
2. Validate envelope/schema.
3. Extract correlation context.
4. Claim/deduplicate before non-idempotent work.
5. Map payload to an application command/domain input.
6. Execute domain behavior.
7. Map outcome to ack/retry/dead-letter.
8. Keep broker types outside the domain boundary.

## Failure modes

- domain service depends on broker SDK types
- acknowledgement before side effect
- schema validation after domain mutation
- duplicate claim performed only in memory
- replay bypasses normal validation

## Testing

Test handler outcomes separately from domain behavior: success/ack, retryable failure, terminal failure, duplicate, invalid schema, and replay.

## Review checklist

- [ ] broker dependency isolated
- [ ] schema validated at boundary
- [ ] deduplication before duplicate-sensitive work
- [ ] domain input normalized
- [ ] ack/retry/dead-letter mapping explicit
- [ ] replay uses same validation path

## Related skills

- rails-event-driven-messaging
- rails-distributed-systems
- rails-active-job
- rails-api-integration
- ruby-dependency-injection

## Related patterns

- inbox-deduplication
- message-delivery-contract
