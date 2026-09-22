---
name: operational-dry-run-contract
description: Operational Dry-Run Contract
family: rails
---
# Operational Dry-Run Contract

## Problem
Operators cannot validate scope before a destructive maintenance operation.

## Use when
Cleanup, backfill, repair, migration-support, or high-volume mutation task.

## Do not use when
A tiny, naturally atomic operation with negligible blast radius.

## Repository inspection
Inspect selection predicate, mutation path, reporting needs, and operator workflow.

## Implementation procedure
Separate selection/reporting from mutation and expose a dry-run or preview mode when useful.

## Failure modes
Dry-run accidentally mutates, preview does not represent actual scope, or reporting leaks sensitive data.

## Testing
Test dry-run produces zero writes while reporting expected scope.

## Review checklist
[ ] dry-run no writes [ ] same selection predicate [ ] safe reporting

## Related skills
rails-operational-tasks-maintenance