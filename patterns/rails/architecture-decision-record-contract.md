---
name: architecture-decision-record-contract
description: Architecture Decision Record Contract
family: architecture
---
# Architecture Decision Record Contract

## Problem
Important architecture decisions are repeatedly revisited when context and tradeoffs are not recorded.

## Use when
A decision materially changes boundaries, dependencies, data ownership, or deployment shape.

## Do not use when
A routine implementation detail with no durable architectural consequence.

## Repository inspection
Inspect existing architecture docs/ADRs and repository conventions.

## Implementation procedure
Record context, problem, constraints, alternatives, decision, consequences, migration, and review trigger without duplicating source code.

## Failure modes
Decision reversals lose context, rejected alternatives forgotten, documentation drifts.

## Testing
Review ADR against implementation and migration evidence.

## Review checklist
[ ] context [ ] alternatives [ ] consequences [ ] migration [ ] review trigger

## Related skills
rails-staff-principal-architecture, agent-workflow