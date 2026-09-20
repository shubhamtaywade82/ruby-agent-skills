---
name: ruby-tdd-refactoring
description: Use when implementing behavior changes, fixing defects, refactoring Ruby/Rails code or improving test coverage.
---

# Ruby TDD and Refactoring

## Purpose
Use tests as executable contracts and refactor in small, verifiable steps.

## Change loop
~~~
text
understand behavior
  -> write/fix a focused test
  -> implement minimum behavior
  -> run focused tests
  -> refactor
  -> run regression suite
~~~

In an existing repository, follow its established test framework and helper conventions.

## Before coding
Inspect tests, fixtures/factories, helpers, mocks/stubs, integration/request tests and CI commands.

Do not introduce a second test style without a reason.

## Test quality
Tests should verify behavior rather than implementation trivia.

Cover normal cases, edge cases and failure behavior. For bugs, add regression coverage.

## Refactoring safety
A refactor changes structure without intentionally changing observable behavior.

Typical sequence:
1. add missing coverage
2. make one structural change
3. run tests
4. inspect the diff
5. repeat

Do not combine a broad refactor with unrelated behavior changes.

## Algorithm tasks
Test normal, empty, singleton, duplicate and boundary cases. Record expected time and space complexity when the requirement specifies complexity.

## Completion criteria
A task is complete when behavior is implemented, relevant tests pass, regression coverage passes, and the final diff contains no unnecessary unrelated changes.

## Source foundation
Based on the TDD, clean-test, implementation and refactoring material in Clean Ruby, combined with the exercise-driven practice model of The Ruby Workshop.