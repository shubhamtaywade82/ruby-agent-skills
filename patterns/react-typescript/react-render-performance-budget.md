---
name: react-render-performance-budget
description: Use evidence to define a rendering performance boundary before optimizing.
family: react-typescript
---

# React Render Performance Budget

## Problem
A component tree exhibits measurable latency, excess renders, or expensive list rendering.

## Use when
No workload evidence shows a performance problem.

## Do not use when
Do not activate simply because the UI contains JavaScript or because an abstraction is available.

## Repository inspection
Inspect profiler traces, list sizes, state ownership, and stable identities.

## Implementation procedure
Identify the hot path, set a measurable budget, and fix ownership or identity issues before adding optimization.

## Failure modes
Premature memoization, arbitrary thresholds, and performance claims from intuition.

## Testing
Use profiler or benchmark evidence plus regression checks where practical.

## Review checklist
What measured workload justifies the optimization?

## Related skills
react-accessibility-performance,react-architecture
