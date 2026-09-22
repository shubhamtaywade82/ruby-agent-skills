---
name: batch-checkpoint-contract
description: Batch Checkpoint and Resumability Contract
family: rails
---
# Batch Checkpoint and Resumability Contract

## Problem
Large operations fail, time out, or hold excessive resources when implemented as one unbounded invocation.

## Use when
High-cardinality data repair, backfill, purge, or reconciliation.

## Do not use when
Very small bounded workloads with proven operational limits.

## Repository inspection
Inspect dataset size, primary key/order, batch APIs, transaction scope, checkpoints, and restart behavior.

## Implementation procedure
Process deterministic batches, persist or infer progress, and make interruption safe.

## Failure modes
Skipped ranges, duplicate work, long transactions, lock contention, memory growth.

## Testing
Test interruption/resume behavior and boundary batches.

## Review checklist
[ ] deterministic batches [ ] progress [ ] interruption safe [ ] bounded transactions

## Related skills
rails-operational-tasks-maintenance, rails-database-engineering, rails-reliability-engineering