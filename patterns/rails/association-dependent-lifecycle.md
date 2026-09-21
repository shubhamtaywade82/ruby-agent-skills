---
name: association-dependent-lifecycle
description: Use when changing dependent behavior or coordinating application and database deletion semantics for an association.
family: rails
---

# Association Dependent Lifecycle

## Problem

dependent options can trigger callbacks, direct deletes, nullification, restrictions, or asynchronous work and may interact with database cascades.

## Use when

- changing dependent
- adding database ON DELETE behavior
- debugging orphaned or unexpectedly deleted records.

## Do not use when

- deletion behavior is unrelated to associations.

## Repository inspection

Inspect both association declarations, database foreign keys/cascades, callbacks, storage cleanup, audits, and transaction boundaries.

## Implementation procedure

1. Define the desired owner/dependent lifecycle.
2. Map application deletion and database deletion independently.
3. Choose destroy/delete/nullify/restrict or asynchronous behavior deliberately.
4. Verify foreign-key compatibility.
5. Test success, restriction, rollback, and cleanup cases.

## Failure modes

- double cleanup
- callbacks expected from database cascades
- nullify against NOT NULL columns
- asynchronous deletion incompatible with foreign keys.

## Testing

Test owner destroy, dependent outcome, callbacks, constraints, and asynchronous behavior where applicable.

## Review checklist

- [ ] lifecycle is explicit
- [ ] DB/application deletion paths are compatible
- [ ] cleanup semantics are preserved
- [ ] rollback behavior is tested

## Related skills

rails-associations, rails-database-engineering, rails-active-record, rails-active-job, rails-active-storage
