---
name: policy-object-boundary
description: Encapsulate a coherent authorization decision in a small policy object.
family: rails
---
# Policy Object Boundary

## Problem
Permission rules are scattered across callers.

## Use when
A resource/action has a stable, testable authorization contract.

## Do not use when
The rule is a single repository-local predicate with no meaningful boundary.

## Structure
A policy receives actor, resource, and explicit context and answers a decision. It does not mutate state or perform unrelated I/O.

## Implementation procedure
Keep action predicates narrow, name domain concepts explicitly, and compose shared predicates carefully.

## Failure modes
God policies, hidden global context, policy-side effects, and duplicated domain invariants.

## Testing
Unit-test decisions independently and verify at least one real application boundary.

## Review checklist
Explicit inputs, deterministic decision, no side effects, clear action semantics.
