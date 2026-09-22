---
name: architecture-problem-statement
description: Architecture Problem Statement Contract
family: architecture
---
# Architecture Problem Statement Contract

## Problem
Architecture work fails when a proposed structure solves a vague discomfort instead of a concrete system problem.

## Use when
Starting or reviewing a material architecture change.

## Do not use when
A localized feature fits an existing boundary without structural change.

## Repository inspection
Inspect incidents, change coupling, dependency graph, performance/reliability/security constraints, and actual pain.

## Implementation procedure
State the problem, affected invariants, measurable cost, and why existing boundaries are insufficient.

## Failure modes
Architecture theatre, overbuilding, solving hypothetical scale, unclear success criteria.

## Testing
Review whether the stated problem is supported by repository evidence.

## Review checklist
[ ] problem concrete [ ] evidence [ ] invariants [ ] success criteria

## Related skills
rails-staff-principal-architecture, rails-architecture