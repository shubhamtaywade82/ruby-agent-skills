---
name: typescript-core-engineering
description: Use for TypeScript language semantics, strictness, modules, narrowing, generics, and public type contracts.
---

# TypeScript Core Engineering

## Purpose
Use TypeScript as a compile-time contract system layered over JavaScript. Make invalid states harder to represent without pretending types are runtime validation.

## Activate when
- changing TypeScript language-level code;
- resolving compiler or type errors;
- designing exported types, generics, unions, or module boundaries;
- reviewing JavaScript to TypeScript migrations.

## Repository inspection
Inspect tsconfig files, package manager, build and test commands, supported Node/runtime, module format, path aliases, strictness flags, and local type conventions.

## Decision rules
- Prefer precise inference for local values.
- Add explicit types at public boundaries and important contracts.
- Prefer discriminated unions over combinations of flags that permit impossible states.
- Use unknown at untrusted boundaries and narrow deliberately.
- Isolate unavoidable any usage.
- Preserve runtime behavior; compile-time types do not validate network, JSON, DOM, or user input.

## Implementation procedure
1. Resolve runtime and compiler constraints.
2. Identify public, domain, transport, and internal boundaries.
3. Model valid states before implementation.
4. Narrow external values before consumption.
5. Keep generic parameters tied to real input/output relationships.
6. Avoid circular module ownership.
7. Update focused tests when behavior or contracts change.

## Anti-patterns / failure modes
- type assertions used to silence uncertainty;
- broad any usage;
- optional properties used as an implicit state machine;
- exported types that leak internal details;
- repository-wide strictness changes to accommodate one feature.

## Verification
Run typecheck, focused tests, lint, and relevant build verification. Test runtime behavior separately when boundary data is involved.

## Source foundation
- TypeScript Handbook: https://www.typescriptlang.org/docs/handbook/intro.html
- TSConfig Reference: https://www.typescriptlang.org/tsconfig/
