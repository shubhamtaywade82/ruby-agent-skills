---
name: architecture-tradeoff-contract
description: Architecture Tradeoff Contract
family: architecture
---
# Architecture Tradeoff Contract

## Problem
A design decision is incomplete when it states benefits but hides latency, operational, migration, security, or team costs.

## Use when
Any material architecture choice with more than one plausible option.

## Do not use when
A local implementation choice with negligible long-term consequence.

## Repository inspection
Inspect constraints and likely alternatives including no-change option.

## Implementation procedure
Compare options across correctness, complexity, performance, reliability, security, migration cost, operations, and ownership.

## Failure modes
Local optimization creates system-wide cost, hidden complexity, unjustified scale assumptions.

## Testing
Require an explicit decision record or review artifact where the repository expects one.

## Review checklist
[ ] alternatives [ ] costs [ ] system effects [ ] no-change considered

## Related skills
rails-staff-principal-architecture, agent-workflow