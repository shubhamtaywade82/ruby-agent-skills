---
name: ruby-method-design
description: Use when creating or refactoring Ruby methods, especially when parameters, return values, nesting or responsibility become difficult to reason about.
---

# Ruby Method Design

## Purpose
Make methods easy to understand, call, test and change.

## Core rules
1. One method should have one primary responsibility.
2. Prefer a small number of parameters.
3. Parameter order should match natural expectations.
4. Keep return behavior predictable.
5. Use guard clauses to reject invalid input early.
6. Avoid deep nesting.
7. Extract cohesive logic instead of shortening methods mechanically.
8. Use names that reveal intent.

## Parameters
When many related parameters appear, investigate whether they represent a real configuration or domain object.

Example:

~~~
ruby
start_game(players, score, rounds, winning_score, network_game)
~~~

may become a real Game/Config concept. Do not introduce a wrapper object purely to satisfy a numeric parameter limit.

## Return contracts
Prefer one predictable family of return values. Avoid methods that sometimes return a domain object and sometimes an unrelated error hash/string.

## Guard clauses
Use early exits when they make preconditions explicit and reduce nesting.

## Refactoring procedure
1. Identify observable behavior.
2. Identify responsibilities.
3. Identify parameter interactions.
4. Identify return branches.
5. Extract cohesive logic.
6. Preserve public behavior.
7. Add or update focused tests.
8. Run regression coverage.

## Anti-patterns
- do-everything methods
- boolean flags that radically change behavior
- multiple unrelated return types
- nested conditionals hiding the happy path
- vague names such as process or handle

## Source foundation
Derived primarily from the method design and refactoring principles in Clean Ruby, supplemented by Ruby method/argument material in The Ruby Workshop.