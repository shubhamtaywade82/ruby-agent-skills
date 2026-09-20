# Skill Routing

Use this file as the routing policy for an agent harness.

## Global policy

Always inspect the repository before applying a skill.

Always activate ruby-clean-code for non-trivial Ruby/Rails code changes.

Activate multiple skills when the task crosses boundaries. Do not force a cross-cutting task into one skill.

## Routing matrix

| Task | Primary skills | Secondary |
|---|---|---|
| Ruby syntax/semantics | ruby-core | ruby-clean-code |
| Array/hash/Enumerable work | ruby-collections | ruby-core, ruby-clean-code |
| New/refactored method | ruby-method-design | ruby-clean-code, ruby-tdd-refactoring |
| Class/domain design | ruby-oop | ruby-method-design, ruby-clean-code |
| Shared behavior | ruby-modules-mixins | ruby-oop, ruby-clean-code |
| Reflection/metaprogramming | ruby-metaprogramming | ruby-clean-code, ruby-tdd-refactoring |
| External I/O/service | ruby-gems-io-services | ruby-debugging, ruby-tdd-refactoring |
| Runtime failure/exception | ruby-debugging | ruby-tdd-refactoring |
| Rails endpoint/feature | rails-architecture | ruby-method-design, ruby-clean-code |
| Database/model change | rails-activerecord | rails-architecture, ruby-tdd-refactoring |
| Code review/refactor | ruby-clean-code | ruby-method-design, ruby-tdd-refactoring |
| Test design | ruby-tdd-refactoring | relevant implementation skill |

## Conflict resolution

1. preserve observable behavior unless the task explicitly changes it
2. follow repository conventions
3. prefer the simpler design
4. keep responsibilities focused
5. prefer explicit Ruby over clever abstraction
6. verify with tests