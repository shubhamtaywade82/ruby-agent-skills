---
name: react-focus-management
description: Define focus entry, movement, and recovery as an explicit interaction contract.
family: react-typescript
---

# React Focus Management

## Problem
Dialogs, menus, routed views, dynamic forms, or async UI changes alter focus context.

## Use when
No focus context changes and native browser behavior already satisfies the workflow.

## Do not use when
Do not activate simply because the UI contains JavaScript or because an abstraction is available.

## Repository inspection
Inspect focus utilities, browser navigation, and restoration expectations.

## Implementation procedure
Capture meaningful prior focus, move focus intentionally, and restore it after the interaction ends.

## Failure modes
Focus traps without recovery, stealing focus on every rerender, and inaccessible loading transitions.

## Testing
Test keyboard navigation, focus restoration, escape/cancel behavior, and unmount cases.

## Review checklist
Where should focus be before, during, and after the interaction?

## Related skills
react-accessibility-performance,react-testing-engineering
