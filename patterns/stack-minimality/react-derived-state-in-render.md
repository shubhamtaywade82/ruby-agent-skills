---
name: react-derived-state-in-render
description: React Derived State In Render
family: stack-minimality
---
# React Derived State In Render

## Problem
Duplicated state creates synchronization code and stale values.

## Use when
A component stores a value derivable from existing props, state, or query data.

## Do not use when
The value represents independent user input or deliberately persisted state.

## Repository inspection
Inspect the relevant application boundary, existing implementations, callers, dependencies, and runtime constraints before introducing a new layer.

## Implementation procedure
Remove redundant state and derive the value during render. Use memoization only when computation cost is measured.

## Failure modes
Effect-driven synchronization, stale derived values, and memoization without evidence.

## Testing
Test rendered output across the inputs that change the derived value.

## Review checklist
[ ] repository evidence checked [ ] smallest valid boundary chosen [ ] required guarantees preserved

## Related skills
react-state-effects, react-accessibility-performance, stack-minimality
