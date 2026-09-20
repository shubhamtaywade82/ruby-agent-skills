# Ruby Agent Skills

A practical skill library for AI coding agents working with Ruby and Ruby on Rails.

This repository turns Ruby/Rails engineering principles into agent-executable instructions: activation triggers, design rules, review procedures, anti-patterns, and validation criteria.

## Skill map

| Skill | Purpose |
|---|---|
| ruby-core | Ruby object model, syntax, expressions, typing, truthiness and execution |
| ruby-collections | Arrays, hashes, Enumerable and collection transformations |
| ruby-method-design | Method responsibility, parameters, return contracts and nesting |
| ruby-oop | Classes, encapsulation, inheritance, polymorphism and composition |
| ruby-modules-mixins | Modules, mixins, namespaces, include, extend and prepend |
| ruby-metaprogramming | Reflection and metaprogramming with safety boundaries |
| ruby-gems-io-services | Gems, filesystem/CSV/HTTP work and service objects |
| ruby-debugging | Logging, stack traces, breakpoints and root-cause debugging |
| rails-architecture | MVC, routing, controllers, REST and application boundaries |
| rails-activerecord | Models, migrations, associations, validations and persistence |
| ruby-clean-code | Readability, simplicity, extensibility, naming and maintainability |
| ruby-tdd-refactoring | Test-first changes, regression safety and behavior-preserving refactoring |

## Design

These are not a book dump or a passive RAG corpus.

Each skill contains:
- activation conditions
- principles and decision rules
- implementation/review procedures
- anti-patterns
- verification criteria
- examples where they clarify behavior

Intended flow:

~~~
text
Task
  -> route to relevant skills
  -> inspect the existing codebase
  -> implement the smallest correct change
  -> test
  -> review against quality skills
  -> refactor only where justified
  -> test again
~~~

## Source foundation

The initial skill set is an original agent-oriented synthesis based on the uploaded:

- The Ruby Workshop — Ruby and Rails fundamentals, OOP, modules/mixins, gems, debugging, metaprogramming, HTTP and Rails.
- Clean Ruby — readability, extensibility, simplicity, naming, method design, boolean logic, classes/modules, refactoring, SRP and TDD.

The repository does not reproduce the books. It converts their concepts into operational instructions for coding agents.

This is an independent project and is not affiliated with Packt Publishing, Apress or the book authors.

## Repository contract

Skills should prefer:
1. correctness over cleverness
2. existing project conventions over invented conventions
3. minimal, reviewable changes over broad rewrites
4. explicit behavior over unnecessary abstraction
5. tests as executable contracts
6. evidence from the repository over assumptions

## Planned next layer

An executable evaluation suite can be added later so the agent is tested for both functional correctness and engineering quality.