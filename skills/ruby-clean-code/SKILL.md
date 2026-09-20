---
name: ruby-clean-code
description: Use globally for Ruby/Rails implementation and review when readability, extensibility, simplicity, naming, responsibility or maintainability matter.
---

# Ruby Clean Code

## Primary quality model
Good Ruby should be:
1. readable
2. easy to change
3. straightforward

These qualities override cleverness.

## Naming
Names should explain the role of the value or operation.

Prefer names such as user_first_name, game_config, player_spawner and pay_bill over vague names such as data, info, manager, process or thing.

Use Ruby naming conventions consistently with the codebase.

## Methods
Check for single responsibility, useful names, reasonable parameter count, predictable returns, limited nesting and absence of redundant variables.

Use guard clauses when they clarify preconditions.

## Classes and modules
A class should have a clear purpose or role. A module should group a coherent capability or concept.

Beware of generic Manager or catch-all utility abstractions.

## Simplicity
Before using metaprogramming, inheritance, complex patterns or framework abstractions, ask whether ordinary Ruby solves the problem more clearly.

## Comments
Keep comments that explain domain constraints, compatibility reasons, surprising external behavior or other information the code cannot communicate well.

Delete comments that merely narrate obvious syntax.

## Refactoring
1. preserve behavior
2. identify the smell
3. make one coherent change
4. run tests
5. inspect the diff
6. repeat

Do not mix unrelated style rewrites with functional changes.

## Review questions
- Can a new developer understand this quickly?
- Do names communicate intent?
- Is every abstraction justified?
- Is responsibility focused?
- Are branches and nesting understandable?
- Are return contracts predictable?

## Source foundation
Directly synthesized from the readability, extensibility, simplicity, naming, methods, classes/modules, boolean-logic and refactoring themes in Clean Ruby.