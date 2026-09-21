---
name: active-record-persistence-lifecycle
description: Use when changing save/update/destroy lifecycle or behavior that depends on persisted state and callbacks.
family: rails
---

# Active Record Persistence Lifecycle

## Problem

Active Record write methods differ in validation, callback, transaction, timestamp, and persistence semantics.

## Use when

- changing save/update/destroy behavior
- replacing one write API with another
- relying on persisted versus in-memory state.

## Do not use when

- the task is exclusively database schema mechanics.

## Repository inspection

Inspect validations, callbacks, associations, transactions, timestamps, bulk APIs, and tests for the affected write path.

## Implementation procedure

1. Identify the exact write operation.
2. List validations and callbacks that must or must not run.
3. Identify transaction ownership.
4. Identify timestamp/dirty-state expectations.
5. Test success, validation failure, and persistence failure.
6. Re-read from the database when post-write truth matters.

## Failure modes

- assuming every write path runs validations
- assuming in-memory state equals persisted state
- changing save to update_columns without lifecycle review
- treating callback execution as atomic external delivery.

## Testing

Cover successful and failing writes plus lifecycle-visible side effects.

## Review checklist

- [ ] write method semantics are known
- [ ] callbacks/validations are intentional
- [ ] transaction boundary is explicit
- [ ] persisted state is verified

## Related skills

rails-active-record, rails-validations, rails-database-engineering, rails-active-job
