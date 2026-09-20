# Skill Routing

This file defines how an agent should select and compose skills.

## Global policy

1. Inspect the repository before implementing.
2. Resolve the Ruby/Rails version before using version-sensitive APIs.
3. Select the smallest set of skills that covers the task.
4. Add `ruby-clean-code` for non-trivial implementation/review work.
5. Add `ruby-tdd-refactoring` for behavior changes, bugs or refactors.
6. Prefer repository evidence over generic assumptions.
7. Never claim verification that was not actually run.

## Routing matrix

| Task | Primary | Secondary |
|---|---|---|
| Ruby syntax/semantics | ruby-core | ruby-clean-code |
| Ruby values/data representation | ruby-data-types | ruby-core, ruby-clean-code |
| Branches/loops/boolean logic | ruby-control-flow | ruby-core, ruby-clean-code |
| Arrays/hashes/Enumerable | ruby-collections | ruby-data-types, ruby-clean-code |
| New/refactored method | ruby-method-design | ruby-clean-code, ruby-tdd-refactoring |
| Class/domain design | ruby-oop | ruby-method-design, ruby-clean-code |
| Shared behavior/namespaces | ruby-modules-mixins | ruby-oop, ruby-clean-code |
| Reflection/metaprogramming | ruby-metaprogramming | ruby-clean-code, ruby-tdd-refactoring |
| File/CSV/HTTP/dependency boundary | ruby-gems-io-services | ruby-debugging, ruby-tdd-refactoring |
| Runtime failure/exception | ruby-debugging | ruby-tdd-refactoring |
| Rails application structure | rails-architecture | ruby-clean-code |
| Rails routes | rails-routing | rails-controllers, rails-testing |
| Rails controller action | rails-controllers | rails-routing, ruby-method-design, rails-testing |
| Rails view/form | rails-views | rails-controllers, rails-testing |
| Model/migration/query | rails-activerecord | rails-architecture, rails-testing |
| Active Record association | rails-associations | rails-activerecord, rails-testing |
| Validation/invariant | rails-validations | rails-activerecord, rails-testing |
| Authentication/session | rails-authentication | rails-controllers, rails-testing |
| Rails test design | rails-testing | relevant implementation skill, ruby-tdd-refactoring |
| Rails generator/scaffold | rails-generators | relevant Rails skill, rails-testing |
| Rails deployment/hosting | rails-deployment | rails-architecture, ruby-debugging |
| Code review/refactor | ruby-clean-code | ruby-method-design, ruby-tdd-refactoring |
| Test-driven change | ruby-tdd-refactoring | relevant implementation skill |

## Composition patterns

### Endpoint + persistence

```text
rails-routing
  + rails-controllers
  + rails-activerecord
  + rails-validations (when invariants change)
  + rails-testing
  + ruby-clean-code
```

### Bug fix

```text
ruby-debugging
  + relevant implementation skill
  + ruby-tdd-refactoring
```

### Cross-cutting refactor

```text
ruby-clean-code
  + affected implementation skill(s)
  + ruby-tdd-refactoring
```

## Conflict resolution

When skills appear to disagree:

1. explicit user requirement wins
2. existing observable behavior and tests come next
3. project conventions next
4. source-backed skill guidance next
5. generic preferences last

When evidence is insufficient, inspect more of the repository instead of guessing.

## Agent execution loop

```text
classify task
  -> resolve version
  -> inspect repository
  -> select skills
  -> state intended change
  -> implement smallest coherent patch
  -> run focused verification
  -> run regression checks
  -> inspect diff
  -> report changed/verified/not-verified
```
