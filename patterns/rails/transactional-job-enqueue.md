---
name: transactional-job-enqueue
description: Align job enqueue timing with database transaction commit semantics.
family: rails
---

# Transactional Job Enqueue

## Problem
A job may execute before transactionally created or updated data is committed.

## Use when
A job is enqueued inside a database transaction and requires committed state.

## Do not use when
The job is independent of the transaction or the repository deliberately accepts eventual consistency before commit.

## Implementation procedure
1. Identify the transaction boundary.
2. Identify data the job reads.
3. Determine adapter/database semantics.
4. Use enqueue_after_transaction_commit when supported and appropriate.
5. Avoid assuming queue and application data share one transaction unless that is an explicit architecture decision.
6. Test commit and rollback behavior.

## Failure modes
- job observes uncommitted/missing state
- enqueue survives a transaction rollback unexpectedly
- correctness accidentally depends on same-database Solid Queue
- switching adapters changes semantics

## Testing
Cover commit, rollback, and enqueue timing at the application boundary.

## Review checklist
- required committed state is explicit
- queue/database relationship is understood
- rollback behavior is tested
- adapter portability is considered

## Related skills
- rails-active-job
- rails-activerecord
- ruby-runtime-compatibility

## Repository inspection

Inspect the repository's runtime/version, existing conventions, neighboring tests or implementation patterns, and the actual owning boundary before applying this pattern.
