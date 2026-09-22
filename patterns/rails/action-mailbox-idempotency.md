---
name: action-mailbox-idempotency
description: Make inbound email business effects safe under duplicate delivery and controlled replay.
family: rails
---

# Action Mailbox Idempotency

## Problem

Transport delivery and business side effects have different guarantees. Provider retries or operational replays can repeat non-idempotent domain changes.

## Use when

- creating records from inbound mail;
- importing commands/events through email;
- adding replay tooling;
- fixing duplicated email effects.

## Do not use when

- processing is observational and has no externally visible side effect.

## Repository inspection

Inspect message identity extraction, domain schema/constraints, existing inbox/idempotency patterns, job enqueue semantics, and replay tooling.

## Implementation procedure

1. Choose the strongest stable message/event identity available.
2. Define key scope.
3. Persist the idempotency decision with the authoritative side effect.
4. Prefer database uniqueness/transactional ownership where appropriate.
5. Preserve original identity during retry/replay.
6. Make duplicate results deterministic.
7. Test repeated and concurrent delivery.

## Failure modes

- timestamp/subject used as identity;
- duplicate check outside the business transaction;
- in-memory dedupe;
- replay bypasses idempotency;
- framework lifecycle status treated as business deduplication.

## Testing

Test same-message repeat, concurrent duplicate processing, replay after failure, and distinct messages with similar content.

## Review checklist

- [ ] stable identity selected
- [ ] scope explicit
- [ ] durable owner explicit
- [ ] uniqueness/transaction protection considered
- [ ] replay preserves identity
- [ ] duplicate outcome deterministic

## Related skills

- skills/rails-action-mailbox/SKILL.md
- patterns/rails/inbox-deduplication.md
- patterns/rails/idempotent-job.md
- skills/rails-database-engineering/SKILL.md
