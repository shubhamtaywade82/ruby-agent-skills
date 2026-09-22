---
name: outbox-publication
description: Persist database changes and the intent to publish a message atomically, then publish from durable outbox state.
family: rails
---

# Outbox Publication

## Problem

A transaction can commit application state and still lose a separately executed message publication.

## Use when

A database mutation and publication of an event/command must be coupled without a distributed transaction.

## Do not use when

The event is non-critical, publication may be reconstructed safely from another durable source, or an existing platform already guarantees the required atomic handoff.

## Repository inspection

Inspect the authoritative database, transaction boundaries, event schema, publisher/worker mechanism, uniqueness constraints, retry/dead-letter handling, and observability.

## Implementation procedure

1. Define the stable event identity and payload contract.
2. Write business state and an outbox record in the same transaction.
3. Mark or claim outbox records durably.
4. Publish with finite retry/backoff.
5. Treat publish ambiguity as potentially duplicated delivery.
6. Record publication outcome/attempt metadata.
7. Retain enough state for replay/reconciliation.
8. Make consumers idempotent.

## Failure modes

- enqueueing/publishing only after commit with no durable handoff
- deleting outbox state before publication is durably accepted
- using random event identity on every retry
- assuming publisher retry means exactly-once delivery
- holding database transactions open across network calls

## Testing

Test commit/rollback, publisher crash before/after send, ambiguous send timeout, duplicate publication, replay, and schema compatibility.

## Review checklist

- [ ] business state and outbox write share one transaction
- [ ] stable event identity
- [ ] bounded publisher retry
- [ ] duplicate publication tolerated
- [ ] replay/reconciliation path exists
- [ ] consumer idempotency exists

## Related skills

- rails-distributed-systems
- rails-database-engineering
- rails-active-job
- rails-observability

## Related patterns

- transaction-boundary
- transactional-job-enqueue
- inbox-deduplication
- message-delivery-contract
