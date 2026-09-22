---
name: scheduled-maintenance-overlap-contract
description: Scheduled Maintenance Overlap Contract
family: rails
---
# Scheduled Maintenance Overlap Contract

## Problem
Schedulers can deliver duplicate, delayed, or overlapping maintenance executions during deploys and outages.

## Use when
Recurring maintenance tasks or jobs.

## Do not use when
An operator-only task invoked manually once.

## Repository inspection
Inspect scheduler semantics, retries, deployment lifecycle, locks, and task idempotency.

## Implementation procedure
Design for at-least-once execution, overlap control, delayed execution, and restart behavior.

## Failure modes
Concurrent runs, missed cleanup, duplicate side effects, and retry storms.

## Testing
Test duplicate trigger and overlapping invocation behavior.

## Review checklist
[ ] duplicate safe [ ] overlap policy [ ] delayed safe [ ] deploy-safe

## Related skills
rails-operational-tasks-maintenance, rails-active-job, rails-reliability-engineering