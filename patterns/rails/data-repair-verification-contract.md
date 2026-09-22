---
name: data-repair-verification-contract
description: Data Repair Verification Contract
family: rails
---
# Data Repair Verification Contract

## Problem
A repair can run successfully at the process level while leaving incorrect data because success criteria are implicit.

## Use when
Backfills, repairs, reconciliation, or corrective scripts.

## Do not use when
Purely diagnostic commands that do not mutate state.

## Repository inspection
Inspect source-of-truth definition, repair predicate, expected postcondition, verification query, and rollback/reconciliation procedure.

## Implementation procedure
Define before/after invariants and execute an explicit verification step as part of the runbook or command output.

## Failure modes
False confidence from zero exceptions despite incorrect state.

## Testing
Test the verification query against good, bad, and partially repaired fixtures.

## Review checklist
[ ] source of truth [ ] postcondition [ ] verification query [ ] recovery

## Related skills
rails-operational-tasks-maintenance, rails-database-engineering