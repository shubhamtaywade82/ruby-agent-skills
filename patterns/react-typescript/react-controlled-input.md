---
name: react-controlled-input
description: Make form control ownership explicit.
family: react-typescript
---

# React Controlled Input

## Problem
A form field must be controlled by application state or intentionally owned by the DOM.

## Use when
The repository already defines a compatible form abstraction and the change would only duplicate it.

## Do not use when
Do not activate simply when The repository already defines a compatible form abstraction and the change would only duplicate it. 

## Repository inspection
Inspect validation, form library, reset behavior, and submission ownership.

## Implementation procedure
Choose one owner, define value/change semantics, and document reset/error behavior.

## Failure modes
Mixing controlled and uncontrolled modes, defaultValue plus value confusion, and hidden state synchronization.

## Testing
Test typing, reset, validation, submit, and rerender behavior.

## Review checklist
Who owns the source of truth at every transition?

## Related skills
react-component-engineering,react-state-effects
