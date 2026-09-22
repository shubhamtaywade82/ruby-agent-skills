---
name: data-ownership-contract
description: Data Ownership Contract
family: architecture
---
# Data Ownership Contract

## Problem
Two subsystems mutating the same source of truth create ambiguous invariants and reconciliation problems.

## Use when
Splitting domains/modules or integrating separate subsystems.

## Do not use when
A single bounded component clearly owns the data and invariant.

## Repository inspection
Inspect schema, writers, callbacks, jobs, events, reports, direct SQL, and migrations.

## Implementation procedure
Name authoritative writer/storage owner; expose reads through stable contracts or projections and route mutations through the owner.

## Failure modes
Dual writers, conflicting validations, stale replicas treated as authoritative.

## Testing
Search all writers and test invariant preservation across boundaries.

## Review checklist
[ ] authoritative owner [ ] writers inventoried [ ] read contract [ ] no dual mutation

## Related skills
rails-staff-principal-architecture, rails-database-engineering