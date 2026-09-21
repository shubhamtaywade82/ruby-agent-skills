---
name: saga-orchestration
description: Coordinate a multi-transaction business workflow with explicit state, compensation, retry, and recovery.
family: rails
---

# Saga Orchestration

## Problem

A business workflow spans independent transaction owners, so no single database transaction can atomically commit the full operation.

## Use when

Multiple services/datastores own separate steps and partial completion must be recovered explicitly.

## Do not use when

A single database transaction can own the invariant or a simpler asynchronous workflow is sufficient.

## Repository inspection

Inspect transaction owners, command/event contracts, workflow persistence, timeouts, retries, compensation behavior, dead-letter/replay tooling, and operator recovery.

## Implementation procedure

1. Define the workflow state machine.
2. Define each step's forward action and success state.
3. Persist durable workflow state.
4. Define timeout and retry policy per step.
5. Define compensating action or explicit manual recovery.
6. Make every step idempotent.
7. Record correlation/causation identifiers.
8. Expose failure/replay state to operators.
9. Test partial completion and recovery.

## Failure modes

- saga used where one local transaction suffices
- compensation assumed to be an exact rollback
- step not idempotent
- workflow state kept only in memory
- infinite retry of an unavailable service
- compensation failure with no recovery path
- hidden coupling through shared database state

## Testing

Test success, timeout, retry, partial completion, duplicate command, compensation success/failure, and replay/resume from persisted state.

## Review checklist

- [ ] independent transaction owners justify saga
- [ ] durable state machine
- [ ] step idempotency
- [ ] compensation semantics explicit
- [ ] bounded retries/timeouts
- [ ] recovery/replay path
- [ ] observability/correlation

## Related skills

- rails-distributed-systems
- rails-active-job
- rails-api-integration
- rails-database-engineering
- rails-observability

## Related patterns

- transaction-boundary
- idempotent-job
- message-delivery-contract
