---
name: react-testing-engineering
description: Use when testing React components, hooks, async UI, user interactions, accessibility, and integration boundaries.
---

# React Testing Engineering

## Purpose
Test observable UI contracts and state transitions while keeping tests deterministic and independent of implementation details.

## Activate when
- adding or repairing React tests;
- testing hooks, forms, async rendering, or user interaction;
- replacing brittle implementation-coupled tests.

## Repository inspection
Inspect the test runner, DOM environment, Testing Library usage, network mocking, fixtures, fake timers, accessibility tooling, and CI commands.

## Decision rules
- Prefer user-observable assertions.
- Prefer role, name, and label queries for accessible controls.
- Mock stable network or module boundaries only when isolation requires it.
- Do not mock React internals or every child by default.
- Synchronize async work explicitly.
- Test rejection and recovery paths.

## Implementation procedure
1. Identify the user-visible contract.
2. Select the smallest boundary that proves it.
3. Control external dependencies.
4. Exercise realistic interaction.
5. Assert UI and meaningful side effects.
6. Add regression cases for prior failures.

## Anti-patterns / failure modes
- asserting private state;
- class-name selectors for semantic behavior;
- sleeps for async synchronization;
- snapshot-only verification;
- disabling accessibility warnings globally.

## Verification
Run focused tests, relevant integration tests, typecheck, and lint.

## Source foundation
- React Learn: https://react.dev/learn
- Testing Library: https://testing-library.com/docs/
