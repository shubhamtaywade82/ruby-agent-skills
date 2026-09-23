---
name: typescript-public-api-boundary
description: Expose stable public types without leaking internal implementation structure.
family: react-typescript
---

# Typescript Public Api Boundary

## Problem
A package or module has consumers outside its immediate implementation.

## Use when
The type is private implementation detail and no consumer contract depends on it.

## Do not use when
Do not activate simply when The type is private implementation detail and no consumer contract depends on it. 

## Repository inspection
Inspect exports, package entrypoints, dependency direction, and compatibility expectations.

## Implementation procedure
Define explicit exported input/output types and map internal structures to them.

## Failure modes
Exporting database or component-private structures, accidental barrel exports, and breaking changes hidden inside inferred types.

## Testing
Compile downstream-style usage and test representative runtime calls.

## Review checklist
Can internals change without forcing consumers to change?

## Related skills
typescript-core-engineering,typescript-type-design
