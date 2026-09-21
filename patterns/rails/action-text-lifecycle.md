---
name: action-text-lifecycle
description: Coordinate Rails Action Text creation, updates, deletion, embedded resources, and transactional/background lifecycle semantics.
family: rails
---

# Action Text Lifecycle

## Problem

RichText storage and embedded attachments can have lifecycle timing different from the owning model's primary-table state.

## Use when

- deleting or replacing rich text;
- changing transactions/callbacks/jobs;
- coordinating attachment cleanup.

## Do not use when

- lifecycle is unchanged.

## Repository inspection

Inspect model deletion, callbacks, transactions, RichText association, Active Storage cleanup, jobs, and retention policies.

## Implementation procedure

1. Define owner lifecycle.
2. Define RichText creation/update timing.
3. Define deletion semantics.
4. Coordinate embedded attachment cleanup.
5. Separate database transaction from external storage work.
6. Test partial/failure cases.

## Failure modes

- rich text orphaned after owner deletion;
- external attachment cleanup assumed atomic;
- callbacks create hidden side effects;
- background cleanup not observable.

## Testing

Test owner creation/update/delete and embedded-attachment lifecycle/failure paths.

## Review checklist

- [ ] owner lifecycle
- [ ] transaction boundary
- [ ] cleanup
- [ ] asynchronous work
- [ ] failures
- [ ] tests

## Related skills

rails-action-text, rails-activerecord, rails-active-storage, rails-active-job
