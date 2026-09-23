---
name: react-optimistic-rollback
description: Pair optimistic UI with a deterministic rollback or reconciliation path.
family: react-typescript
---

# React Optimistic Rollback

## Problem
A mutation updates UI before the server confirms success.

## Use when
The mutation is destructive, non-idempotent, or too expensive to reconcile safely.

## Do not use when
Do not activate simply when The mutation is destructive, non-idempotent, or too expensive to reconcile safely. 

## Repository inspection
Inspect mutation semantics, cache ownership, and server idempotency.

## Implementation procedure
Snapshot prior state, apply the optimistic change, reconcile on success, and restore or invalidate on failure.

## Failure modes
Optimistic updates without rollback, stale snapshots, or assuming network success.

## Testing
Test success, failure, duplicate action, and out-of-order response.

## Review checklist
What exact state is restored when the mutation fails?

## Related skills
react-data-fetching,react-state-effects
