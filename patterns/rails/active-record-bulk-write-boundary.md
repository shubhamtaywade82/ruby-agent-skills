---
name: active-record-bulk-write-boundary
description: Use when using or reviewing update_all, delete_all, destroy_all, upsert, import, or other bulk persistence APIs.
family: rails
---

# Active Record Bulk Write Boundary

## Problem

Bulk operations trade object lifecycle semantics for bounded database work and can silently bypass validations, callbacks, or per-record behavior.

## Use when

- processing large datasets
- replacing per-record writes
- adding bulk update/delete/upsert behavior.

## Do not use when

- per-record lifecycle behavior is part of the required contract.

## Repository inspection

Inspect validations, callbacks, timestamps, dependent behavior, auditing, events, constraints, and performance requirements.

## Implementation procedure

1. State which lifecycle features may be bypassed.
2. Move required invariants to database constraints where appropriate.
3. Preserve audit/event behavior explicitly.
4. Bound batch size and execution time where applicable.
5. Test both data outcome and intentionally skipped lifecycle behavior.

## Failure modes

- replacing destroy_all with delete_all blindly
- assuming callbacks fire
- bypassing tenant filters
- using bulk APIs without database constraints.

## Testing

Verify row counts, data state, callbacks/events that should occur, and constraints that remain authoritative.

## Review checklist

- [ ] bypassed lifecycle is intentional
- [ ] invariants have authoritative enforcement
- [ ] tenant/security predicates remain
- [ ] batch/capacity behavior is bounded

## Related skills

rails-active-record, rails-database-engineering, rails-security, rails-performance
