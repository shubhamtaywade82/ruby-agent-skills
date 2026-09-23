---
name: react-reducer-state-machine
description: Use a reducer when UI transitions form a meaningful state machine.
family: react-typescript
---

# React Reducer State Machine

## Problem
Many related events update coupled state or the valid transitions are easier to express as actions.

## Use when
State is trivial and one or two local transitions are easier with useState.

## Do not use when
Do not activate simply when State is trivial and one or two local transitions are easier with useState. 

## Repository inspection
Inspect transition count, invalid transitions, and action ownership.

## Implementation procedure
Define explicit actions and a reducer that preserves valid states; keep side effects outside the reducer.

## Failure modes
Reducers used as generic state containers, hidden side effects, and arbitrary string actions.

## Testing
Test action-to-state transitions and invalid actions.

## Review checklist
Are transitions easier to reason about as named events?

## Related skills
react-state-effects,typescript-type-design
