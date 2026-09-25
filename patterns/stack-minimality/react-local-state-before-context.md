---
name: react-local-state-before-context
description: React Local State Before Context
family: stack-minimality
---
# React Local State Before Context

## Problem
Global providers increase coupling and rerender scope when state is local to one feature or subtree.

## Use when
Choosing local state, props, context, or external state.

## Do not use when
Multiple legitimate consumers require a shared owner.

## Repository inspection
Inspect the relevant application boundary, existing implementations, callers, dependencies, and runtime constraints before introducing a new layer.

## Implementation procedure
Trace state readers and writers and provider boundaries. Keep state at the smallest common owner.

## Failure modes
Global-by-default state, provider nesting, and hidden dependencies.

## Testing
Test user behavior and state ownership effects at the feature boundary.

## Review checklist
[ ] repository evidence checked [ ] smallest valid boundary chosen [ ] required guarantees preserved

## Related skills
react-state-effects, react-architecture, react-testing-engineering, stack-minimality
