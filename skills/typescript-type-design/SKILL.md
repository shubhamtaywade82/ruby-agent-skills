---
name: typescript-type-design
description: Use when modeling TypeScript domain states, discriminated unions, generics, branded identifiers, utility types, or public APIs.
---

# TypeScript Type Design

## Purpose
Design types that express domain invariants and API contracts without turning the type system into accidental architecture.

## Activate when
- a feature needs new domain types;
- boolean flags create invalid combinations;
- a library exposes reusable generic types;
- structurally identical primitives need stronger distinctions.

## Repository inspection
Inspect existing exported types, naming, strict null checks, generated API types, utility-type conventions, and package ownership.

## Decision rules
- Model mutually exclusive states as discriminated unions.
- Use branded or opaque-style types only where mixing primitives is materially risky.
- Use generics when a real relationship must be preserved across inputs and outputs.
- Prefer narrow object types over catch-all records when keys are known.
- Derive small variants from stable source types instead of duplicating large shapes.
- Separate transport and domain types when their lifecycle or ownership differs.

## Implementation procedure
1. Write the valid-state table.
2. Identify discriminants and shared fields.
3. Separate transport, domain, and UI representations where useful.
4. Make nullability explicit.
5. Add compile-time contract examples for critical exports.
6. Add runtime tests where external data can violate the declared type.

## Anti-patterns / failure modes
- overlapping union members;
- Partial used as a domain model;
- branded types propagated without a concrete risk;
- generic abstractions that hide the real API;
- assuming a type declaration validates runtime data.

## Verification
Use typecheck-focused tests, exported API compilation checks, and runtime boundary tests for serialized or user-controlled data.

## Source foundation
- TypeScript Narrowing: https://www.typescriptlang.org/docs/handbook/2/narrowing.html
- TypeScript Generics: https://www.typescriptlang.org/docs/handbook/2/generics.html
