---
name: react-composition-over-boolean-props
description: Use composition to express structural variation instead of growing a boolean prop matrix.
family: react-typescript
---

# React Composition Over Boolean Props

## Problem
A component is accumulating flags that alter large portions of structure.

## Use when
A flag controls one small stable visual variation and remains readable.

## Do not use when
Do not activate simply when A flag controls one small stable visual variation and remains readable. 

## Repository inspection
Inspect all prop combinations and conditional branches.

## Implementation procedure
Replace structurally distinct variants with children, slots, or small composed components.

## Failure modes
Impossible flag combinations and deeply nested ternaries.

## Testing
Test each composed variant and shared behavior.

## Review checklist
Can invalid combinations disappear from the API?

## Related skills
react-component-engineering
