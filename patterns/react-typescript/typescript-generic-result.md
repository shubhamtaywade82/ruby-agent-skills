---
name: typescript-generic-result
description: Use a focused generic result contract when success and failure data vary while the protocol stays stable.
family: react-typescript
---

# Typescript Generic Result

## Problem
Several APIs share a success/failure protocol with different payload types.

## Use when
Generics would obscure a single concrete contract or only save a few duplicated lines.

## Do not use when
Do not activate simply when Generics would obscure a single concrete contract or only save a few duplicated lines. 

## Repository inspection
Inspect existing Result, Promise, error, and response conventions.

## Implementation procedure
Define the smallest generic relationship and preserve exhaustive narrowing for success/failure.

## Failure modes
Generic wrappers around every function, unconstrained type parameters, and nested generic aliases.

## Testing
Compile representative success/failure assignments and test runtime behavior at boundaries.

## Review checklist
Does the type parameter express a real relationship?

## Related skills
typescript-type-design,typescript-core-engineering
