# Ruby Agent Skills

A practical skill library for AI coding agents working with Ruby and Ruby on Rails.

The repository converts Ruby/Rails engineering material into agent-executable instructions: activation triggers, decision rules, implementation procedures, anti-patterns, verification criteria and evaluation cases.

## Current skill map

### Ruby

| Skill | Purpose |
|---|---|
| ruby-core | Ruby semantics, object model and runtime behavior |
| ruby-data-types | Core value/data representation |
| ruby-control-flow | Branching, loops and boolean logic |
| ruby-collections | Arrays, hashes and Enumerable |
| ruby-method-design | Method responsibility and contracts |
| ruby-oop | Classes, encapsulation, inheritance, composition |
| ruby-modules-mixins | Modules, mixins and namespaces |
| ruby-metaprogramming | Reflection and runtime behavior |
| ruby-gems-io-services | Dependencies, I/O, HTTP and service boundaries |
| ruby-debugging | Evidence-driven debugging |
| ruby-clean-code | Readability, simplicity and maintainability |
| ruby-tdd-refactoring | Tests, regression safety and refactoring |

### Rails

| Skill | Purpose |
|---|---|
| rails-architecture | MVC and application boundaries |
| rails-routing | Routes, resources and dispatch |
| rails-controllers | Actions, params and responses |
| rails-views | ERB, helpers and forms |
| rails-activerecord | Models, migrations, persistence and queries |
| rails-associations | Active Record relationships |
| rails-validations | Validation and invariants |
| rails-authentication | Authentication and protected access |
| rails-testing | Rails test placement and coverage |
| rails-generators | Generators and scaffolding |
| rails-deployment | Deployment and hosting verification |

## Agent operating model

```text
Task
  -> classify
  -> resolve Ruby/Rails version
  -> inspect repository
  -> route to one or more skills
  -> implement smallest coherent change
  -> focused verification
  -> regression verification
  -> review diff
  -> report facts and verification
```

Skills are intentionally composable. A Rails endpoint that changes persistence should not be forced through one monolithic Rails skill.

## Source foundation

The initial source set includes the uploaded *The Ruby Workshop* and *Clean Ruby* materials.

The Ruby Workshop covers Ruby programs, data types, program flow, methods, OOP, modules/mixins, gems and I/O, debugging, metaprogramming, HTTP and Rails topics including MVC, routes, forms, Active Record, authentication, associations, validations, scaffolding and hosting.

Clean Ruby focuses on readable, changeable and straightforward code, then develops naming, method design, boolean logic, classes, refactoring and TDD.

The Allerin assessment is treated as an evaluation source rather than copied into the skills. Its tasks include sorting, missing values, shopping-cart behavior, triplet sum, majority element, distinct values, power-of-two detection and Chocolate Feast, with an explicit OOP requirement.

The repository does not reproduce the books. It turns their ideas into operational instructions for agents and uses the assessment as a benchmark corpus.

## Design principles

- evidence over assumptions
- repository conventions over invented conventions
- explicit behavior over unnecessary abstraction
- readable code over clever code
- tests as executable contracts
- small, reviewable changes
- version-aware implementation
- deterministic verification

## Repository structure

```text
ruby-agent-skills/
├── skills/
├── router/
│   └── ROUTING.md
├── docs/
│   ├── SKILL_CONTRACT.md
│   └── SOURCE_COVERAGE.md
├── evals/
│   ├── README.md
│   └── ruby-training/
└── skill-manifest.yml
```

## Evaluation direction

The evaluation layer measures functional correctness, contract correctness, engineering quality, test quality, constraint adherence and scope control independently. See `evals/`.

## Status

This branch is the second-stage expansion of the initial 12-skill foundation. The next work is to strengthen every existing skill with the same agent contract, expand the evaluation corpus, validate routing coverage and add installation/release tooling.
