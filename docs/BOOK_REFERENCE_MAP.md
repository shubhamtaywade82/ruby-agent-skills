# Book Reference Map for Ruby Agent Skills

This map records how the uploaded books inform the skills in this repository. The goal is to convert their ideas into concise, testable agent instructions—not to reproduce book text or treat one edition as current framework documentation.

## Sources and applicability

| Book | Scope used in this pack | Version boundary |
|---|---|---|
| David A. Black, *The Well-Grounded Rubyist*, 2nd edition (Manning, 2014) | Ruby object model, methods, classes/modules, scope, control flow, built-ins, collections, IO, blocks/Procs/lambdas, threads, metaprogramming, hooks and introspection | The preface identifies Ruby 2.1 as the edition's target. Use it for conceptual foundations; resolve the project's Ruby version and check current docs before using version-specific syntax or APIs. |
| Carleton DiLeo, *Clean Ruby: A Guide to Crafting Better Code for Rubyists* (Apress, 2019) | Readability, changeability, simplicity, naming, method contracts, Boolean logic, classes, refactoring, TDD and clean tests | Principles are the focus. Method-length and parameter-count heuristics are review signals, not hard gates. Repository conventions and behavior contracts remain authoritative. |
| Noel Rappin, *Modern Front-End Development for Rails*, 2nd edition (Pragmatic Bookshelf, 2022) | Rails frontend architecture, Hotwire/Turbo, Stimulus, React, CSS, TypeScript, bundling, server communication, Action Cable, frontend state and Cypress testing | The book describes Rails 7-era tooling and React 17. Use architectural comparisons; inspect current Rails/frontend versions and the repository's asset/test setup before applying commands or APIs. |

## Chapter-to-skill coverage

### *The Well-Grounded Rubyist*

| Chapter/topic | Skill coverage |
|---|---|
| 1. Ruby execution, syntax, loading features, IRB and tooling | `ruby-core`, `ruby-toolchain`, `ruby-runtime-compatibility`, `ruby-gems-io-services`, `ruby-debugging` |
| 2. Objects, messages, method calls/arguments, returns, references | `ruby-core`, `ruby-method-design`, `ruby-api-design` |
| 3. Classes/instances, state, attributes, inheritance, class methods/constants | `ruby-oop`, `ruby-poro`, `ruby-domain-modeling` |
| 4. Modules, mixins, method lookup, `prepend`, `super`, `method_missing` | `ruby-modules-mixins`, `ruby-oop`, `ruby-metaprogramming` |
| 5. `self`, scope, constants, private/protected visibility | `ruby-core`, `ruby-oop`, `ruby-method-design` |
| 6. Conditionals, loops, blocks/iterators and exceptions | `ruby-control-flow`, `ruby-boolean-logic`, `ruby-blocks-procs-lambdas`, `ruby-debugging` |
| 7–9. Built-in objects, conversions, nil/equality, strings/symbols/numbers, Arrays/Hashes/Ranges/Sets | `ruby-core`, `ruby-data-types`, `ruby-collections` |
| 10. Enumerable/Enumerator, sorting, reduction, chaining and lazy iteration | `ruby-enumerables`, `ruby-collections` |
| 11–12. Regular expressions, files, IO, directories and standard-library helpers | `ruby-data-types`, `ruby-gems-io-services`, `ruby-debugging` |
| 13. Singleton classes, core-class modification and refinements | `ruby-metaprogramming`, `ruby-modules-mixins` |
| 14. Procs/lambdas, Method objects, eval, threads and subprocesses | `ruby-blocks-procs-lambdas`, `ruby-concurrency`, `ruby-gems-io-services`, `ruby-metaprogramming` |
| 15. Hooks, `method_missing`, reflection and stack traces | `ruby-metaprogramming`, `ruby-debugging` |

### *Clean Ruby*

| Chapter/topic | Skill coverage |
|---|---|
| 1. Readability, extensibility and simplicity | `ruby-clean-code`, `stack-minimality` |
| 2. Naming variables, methods, classes and modules | `ruby-clean-code`, `ruby-method-design`, `ruby-oop`, `ruby-modules-mixins` |
| 3. Parameters, return values, guard clauses, length, comments and nesting | `ruby-method-design`, `ruby-clean-code`, `ruby-api-design` |
| 4. Boolean logic, `unless`, ternaries, truthiness, `&&` versus `&` | `ruby-boolean-logic`, `ruby-control-flow`, `ruby-clean-code` |
| 5. Initialization, class/instance methods, accessors, visibility, modules and inheritance | `ruby-oop`, `ruby-poro`, `ruby-object-composition` |
| 6. Small refactorings and Single Responsibility Principle | `ruby-clean-code`, `ruby-tdd-refactoring` |
| 7. TDD, incremental implementation and clean tests | `ruby-tdd-refactoring`, `rails-test-engineering` |

### *Modern Front-End Development for Rails*

| Chapter/topic | Skill coverage |
|---|---|
| 1. Client-side Rails setup and frontend architecture | `rails-application-bootstrap`, `rails-asset-build-engineering` |
| 2–3. Turbo Drive/Frames/Streams and Stimulus | `rails-hotwire`, `rails-action-view` |
| 4. React components and Rails integration | `rails-react-integration`; React internals belong to `react-agent-skills` |
| 5–7. CSS, TypeScript, bundling, Propshaft and import maps | `rails-asset-build-engineering`, `rails-react-integration`; detailed TypeScript belongs to `react-agent-skills` |
| 8. Forms, AJAX/server communication and client data | `rails-hotwire`, `rails-react-integration`, `rails-api-integration`, `rails-validations` |
| 9. Action Cable with Turbo, Stimulus and React | `rails-action-cable`, `rails-hotwire`, `rails-react-integration` |
| 10. Stimulus-managed UI state | `rails-hotwire` |
| 11–13. React reducers/context/Redux and advanced TypeScript | Rails/client boundary: `rails-react-integration`; client internals: `react-agent-skills` |
| 14–15. Cypress, end-to-end testing and troubleshooting | `rails-test-engineering` and the relevant frontend skills |

## Operating rules for agents

1. Inspect `.ruby-version`, `.tool-versions`, Gemfile/Gemfile.lock, package manifests, lockfiles, CI and deployment configuration before adopting book techniques.
2. Use books to understand concepts and trade-offs; verify version-sensitive behavior against current official documentation and installed dependencies.
3. Load the owning skill rather than duplicating the same guidance across several skills.
4. Keep all explanations and examples in the pack original; do not copy chapters, extended passages or sample programs.
5. A chapter mapping means the skill covers the concept, not that every recommendation in the book is a mandatory rule.

## Current documentation to cross-check

- Ruby releases and version status: https://www.ruby-lang.org/en/downloads/releases/
- Ruby documentation: https://docs.ruby-lang.org/en/
- Rails Guides: https://guides.rubyonrails.org/
- Rails API documentation: https://api.rubyonrails.org/
- Hotwire documentation: https://hotwired.dev/
- TypeScript handbook: https://www.typescriptlang.org/docs/
- Cypress documentation: https://docs.cypress.io/
