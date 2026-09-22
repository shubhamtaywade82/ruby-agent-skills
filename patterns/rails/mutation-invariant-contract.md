---
name: mutation-invariant-contract
description: Maintenance Mutation Invariant Contract
family: rails
---
# Maintenance Mutation Invariant Contract

## Problem
Bulk maintenance can bypass callbacks, validations, authorization, or audit behavior that business invariants depend on.

## Use when
Using update_all, delete_all, direct SQL, or low-level writes in maintenance.

## Do not use when
Operations that use normal model behavior and have no bypass.

## Repository inspection
Inspect callbacks, validations, constraints, audit events, jobs, counters, timestamps, and authorization assumptions.

## Implementation procedure
Document intentionally bypassed behavior and reproduce any required invariant explicitly or choose safer writes.

## Failure modes
Corrupted counters, missing audit events, orphaned data, authorization bypass, stale denormalizations.

## Testing
Verify database and application invariants before and after representative mutations.

## Review checklist
[ ] invariants inventoried [ ] bypass justified [ ] recovery verified

## Related skills
rails-operational-tasks-maintenance, rails-active-record, rails-authorization