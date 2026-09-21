---
name: system-test-contract
description: Use Rails system tests only for user-visible browser behavior that lower-level tests cannot prove reliably.
family: testing
---

# System Test Contract

## Problem
Browser/system tests provide realistic coverage but add substantial setup and runtime cost.

## Use when
Testing JavaScript, browser navigation, UI interaction, or full user journeys.

## Do not use when
A model, service, request, or integration test can prove the contract without a browser.

## Procedure
1. Identify the user-visible behavior.
2. Define the minimal journey.
3. Keep data setup explicit.
4. Assert user-observable outcomes.
5. Capture screenshots on failure when useful.
6. Keep business-rule assertions in lower-level tests.

## Failure modes
- browser test for pure domain logic
- giant end-to-end scenario covering unrelated features
- brittle CSS/DOM internals
- duplicate assertions from lower-level tests

## Testing
Run the system test and the lower-level contract tests it complements.

## Review checklist
- browser dependency is justified
- journey is minimal
- assertions are user-visible
- business rules are tested lower in the stack
