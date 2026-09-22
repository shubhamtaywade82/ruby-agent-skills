---
name: partial-failure-contract
description: Operational Partial Failure Contract
family: rails
---
# Operational Partial Failure Contract

## Problem
Long maintenance runs can leave a mixed state when some records fail and error policy is implicit.

## Use when
Tasks processing many independent records.

## Do not use when
Atomic operations where any failure must roll back everything.

## Repository inspection
Inspect dependency failures, retry semantics, error reporting, and operator recovery workflow.

## Implementation procedure
Choose fail-fast, collect-and-report, selective retry, or reconciliation semantics and make them visible in the final result.

## Failure modes
Silent skipped records, endless retries, false success, or incomplete reporting.

## Testing
Inject representative failures and verify reported and persisted outcomes.

## Review checklist
[ ] failure policy [ ] visible result [ ] retry/reconcile [ ] exit status

## Related skills
rails-operational-tasks-maintenance, rails-reliability-engineering