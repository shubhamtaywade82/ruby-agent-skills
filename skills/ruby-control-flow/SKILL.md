---
name: ruby-control-flow
description: Use when implementing or refactoring conditionals, case expressions, loops, boolean branches or repetitive program flow in Ruby.
---

# Ruby Control Flow

## Purpose

Make branching and repetition explicit, correct and easy to reason about.

## Decision rules

- Use a conditional when the decision is genuinely boolean.
- Use `case` when selecting among multiple meaningful alternatives.
- Prefer guard clauses when they make invalid/precondition states exit early.
- Prefer iteration that expresses intent (`each`, `map`, `while`, `until`, ranges) over clever control tricks.
- Avoid deeply nested conditionals; extract a predicate or cohesive method when the logic becomes difficult to read.
- Keep loop termination conditions obvious.
- Do not silently change mutation or break/next behavior during refactoring.

## Boolean logic

Be explicit about:
- truthiness
- short-circuiting
- operator precedence
- negation
- nil handling

For complicated predicates, consider a well-named predicate method so the calling code reads like a domain statement.

## Loops and algorithms

For algorithmic tasks, state:
- input/output contract
- time complexity
- auxiliary space
- mutation
- termination conditions
- edge cases

Do not replace a required algorithm with a convenience abstraction that violates the stated complexity.

## Refactoring procedure

1. characterize current branches
2. identify the happy path
3. isolate guards and predicates
4. simplify one branch at a time
5. preserve observable behavior
6. add focused tests for boundary cases

## Anti-patterns

- nested conditionals that hide the main path
- infinite or ambiguous loops
- duplicated conditions
- boolean expressions whose precedence is unclear
- clever one-liners that obscure control flow

## Source foundation

Derived from the program-flow material in The Ruby Workshop and boolean-logic/readability guidance in Clean Ruby.
