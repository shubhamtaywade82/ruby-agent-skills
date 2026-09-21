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
├── patterns/
│   ├── ruby-design/
│   ├── rails/
│   ├── testing/
│   └── algorithms/
├── router/
│   └── ROUTING.md
├── docs/
│   ├── SKILL_CONTRACT.md
│   ├── PATTERN_SCHEMA.md
│   └── SOURCE_COVERAGE.md
├── evals/
│   ├── schema/
│   ├── ruby-training/
│   ├── algorithms/
│   ├── oop/
│   └── rails/
└── skill-manifest.yml
```

## Implementation patterns

Patterns are concrete, reusable implementation shapes selected after skills classify a task.

Current families include:

| Family | Examples |
|---|---|
| Ruby design | value object, service object, strategy, composition, adapter |
| Rails | query object, form object, policy boundary, transaction boundary, request flow |
| Testing | regression test |
| Algorithms | two pointers, frequency map |

See `patterns/README.md` and `docs/PATTERN_SCHEMA.md`.

Patterns are optional. Existing repository conventions and direct/simple implementations take precedence.

## Evaluation corpus

Phase 5 adds a machine-readable Ruby training benchmark derived from the Allerin assessment.

Current corpus:

- selection sort
- recursive selection sort
- smallest missing number
- shopping cart
- triplet sum
- majority element
- distinct elements
- power-of-two detection
- Chocolate Feast

Each case separates:

- functional behavior
- explicit complexity/algorithm constraints
- OOP/design requirements
- tests and edge cases
- scope control

See `evals/README.md` and `docs/EVAL_SCHEMA.md`.

## Benchmark runner

Phase 6 adds a provider-neutral execution harness:

```text
ruby bin/eval list
  -> ruby bin/eval show EVAL_ID
  -> ruby bin/eval packet EVAL_ID
  -> ruby bin/eval run EVAL_ID --workspace ... --agent-command ... --verify-command ...
```

The runner executes agents in a disposable workspace, captures process output and patch evidence, optionally runs a verifier, and records dimension-level results. See `docs/BENCHMARK_RUNNER.md` and `docs/EVAL_RESULT_SCHEMA.md`.

## Status

The branch contains the Phase 4 implementation-pattern system, the Phase 5 evaluation corpus, the Phase 6 benchmark runner, the Phase 7 fixture/verifier infrastructure and the Phase 8 controlled repeated benchmark campaign. A real campaign now only requires an external agent adapter command. Hidden benchmark packs should remain outside the public repository.


## Controlled agent campaign

Phase 8 materializes only the skills and patterns declared by each evaluation when `RUBY_AGENT_SKILLS_ENABLED=true`. Baseline runs receive the same task and fixture without those selected skills.

See:

- `docs/AGENT_ADAPTER_PROTOCOL.md`
- `docs/BENCHMARK_CAMPAIGN.md`
- `benchmarks/ruby-training/campaign.yml`
