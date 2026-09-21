---
name: batched-backfill
description: Execute large data transformations incrementally and resumably without loading the whole table into memory.
family: rails
---

# Batched Backfill

## Problem
Large migrations can monopolize locks, memory, CPU, and database I/O.

## Use when
Existing rows must be transformed or populated in production-scale data.

## Do not use when
The dataset is demonstrably small and a single bounded transaction is explicitly acceptable.

## Implementation procedure
1. Determine row volume and acceptable load.
2. Choose deterministic batching/cursor ordering.
3. Process bounded batches.
4. Keep each transaction short.
5. Make each batch idempotent.
6. Record progress or make progress discoverable.
7. Retry only safe failures.
8. Define a completion/verification query.

## Failure modes
- loading millions of rows into Ruby
- one transaction around the entire backfill
- non-idempotent batches
- unbounded retry or no progress visibility

## Testing
Test empty, partial, repeated, and failure/restart cases.

## Review checklist
- bounded batch size
- deterministic traversal
- resumable
- idempotent
- progress measurable


## Repository inspection

Inspect runtime/version, repository conventions, the owning boundary, neighboring implementations, and applicable tests before applying the pattern.


## Related skills

- rails-testing
- ruby-tdd-refactoring
- rails-architecture
