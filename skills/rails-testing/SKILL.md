---
name: rails-testing
description: Use when adding or changing Rails behavior and deciding where model, request, controller, system or integration tests belong.
---

# Rails Testing

## Purpose

Verify Rails behavior at the boundary where the contract actually exists.

## Inspect first

Determine the repository's test stack and conventions:
- RSpec or Minitest
- factories or fixtures
- helper modules
- request/system tests
- service/object tests
- CI commands

Do not introduce a second testing ecosystem without a concrete reason.

## Test placement

Prefer the smallest test that proves the behavior, but include integration coverage when the behavior crosses Rails boundaries.

Examples:
- model invariant -> model test
- service workflow -> unit/service test
- HTTP endpoint contract -> request/integration test
- user-visible flow -> system test when the repository uses them

## Test design

Tests should make the contract obvious.

Cover:
- normal behavior
- meaningful edge cases
- invalid input
- authorization/authentication
- failure behavior
- regressions for bugs

Avoid tests that only assert private implementation details unless that implementation is itself an explicit contract.

## Change loop

1. reproduce/describe behavior
2. add or modify the focused test
3. implement the minimum change
4. run focused tests
5. run relevant regression tests
6. inspect the final diff

## Verification

Prefer deterministic tests. Avoid unnecessary sleeps, order dependencies and hidden external network calls.

## Source foundation

Combines the testing/TDD practice in Clean Ruby and the generated-test/activity model in The Ruby Workshop.
