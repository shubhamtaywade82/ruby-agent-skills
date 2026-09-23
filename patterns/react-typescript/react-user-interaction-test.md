---
name: react-user-interaction-test
description: Test what the user can observe and do instead of component implementation details.
family: react-typescript
---

# React User Interaction Test

## Problem
Adding regression coverage for React UI behavior.

## Use when
A lower-level pure function has a simpler deterministic contract.

## Do not use when
Do not activate simply when A lower-level pure function has a simpler deterministic contract. 

## Repository inspection
Inspect accessibility roles, user events, and external boundaries.

## Implementation procedure
Render at the smallest useful boundary, perform realistic interaction, and assert visible outcomes.

## Failure modes
Private-state assertions, CSS-selector coupling, and arbitrary sleeps.

## Testing
Test success, rejection, and recovery paths using deterministic synchronization.

## Review checklist
Would the test survive a component refactor that preserves behavior?

## Related skills
react-testing-engineering
