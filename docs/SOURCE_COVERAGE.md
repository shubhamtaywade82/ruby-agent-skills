# Source Coverage Map

This document records how the uploaded learning material is converted into operational agent skills.

The repository intentionally synthesizes concepts rather than reproducing source text.

## The Ruby Workshop

| Source area | Agent coverage |
|---|---|
| Writing and running Ruby programs | ruby-core |
| Ruby data types and operations | ruby-core, ruby-data-types, ruby-collections |
| Program flow | ruby-control-flow, ruby-boolean-logic |
| Ruby methods | ruby-method-design, ruby-api-design |
| Object-oriented programming | ruby-oop, ruby-poro, ruby-object-composition |
| Modules and mixins | ruby-modules-mixins |
| RubyGems, files, CSV and service classes | ruby-gems-io-services, ruby-service-objects |
| Debugging | ruby-debugging |
| Metaprogramming/reflection | ruby-metaprogramming, metaprogramming-boundary |
| Blocks/Procs/lambdas | ruby-blocks-procs-lambdas |
| Enumerable and collection design | ruby-enumerables, ruby-collections |
| HTTP/client integration | ruby-gems-io-services, external-api-client, ruby-dependency-injection |
| Rails MVC/application anatomy | rails-architecture |
| Rails routes/controllers/views/forms | rails-routing, rails-controllers, rails-views |
| Models, migrations, Active Record and console | rails-activerecord |
| Authentication | rails-authentication |
| Associations | rails-associations |
| Validations | rails-validations |
| Scaffolding | rails-generators, scaffold-lifecycle |
| Hosting/deployment activity | rails-deployment |

## Clean Ruby

| Source area | Agent coverage |
|---|---|
| Qualities of clean code | ruby-clean-code |
| Naming | ruby-clean-code |
| Quality methods | ruby-method-design, ruby-clean-code, ruby-api-design |
| Boolean logic | ruby-boolean-logic, ruby-clean-code |
| Classes | ruby-oop, ruby-poro, ruby-object-composition |
| Refactoring | ruby-clean-code, ruby-tdd-refactoring |
| Test-driven development | ruby-tdd-refactoring |

## Learn Rails 6

The uploaded Learn Rails 6 book adds practical Rails workflow and Ruby language material. The repository uses it to deepen existing skills and add focused gaps rather than cloning chapters.

| Source area | Agent coverage |
|---|---|
| Rails application anatomy and MVC lifecycle | rails-architecture, request-flow |
| RESTful resources and CRUD | rails-routing, rails-controllers, rest-resource |
| Strong parameters and controller boundary | rails-controllers, request-flow |
| before_action filters | rails-controllers, rails-authentication |
| Service objects | ruby-service-objects, ruby-api-design, application-service, service-object |
| Request-level testing | rails-testing, ruby-tdd-refactoring |
| Blocks, Proc and lambda semantics | ruby-blocks-procs-lambdas |
| Enumerable and collection choices | ruby-enumerables, ruby-collections |
| Public method/API contracts | ruby-api-design, ruby-method-design |
| Boolean/truthiness decisions | ruby-boolean-logic, ruby-control-flow |
| External HTTP client boundary | ruby-gems-io-services, external-api-client, adapter |
| Ruby gem boundary | ruby-gems-io-services, ruby-gem |
| Metaprogramming safety | ruby-metaprogramming, metaprogramming-boundary |
| Scaffold cleanup | rails-generators, scaffold-lifecycle |

The book-derived benchmark family is evals/ruby-workshop and benchmarks/ruby-workshop.

## Design-pattern layer

The repository now separates design knowledge into:

- **skills**: when/why to choose an architectural or implementation approach
- **patterns**: concrete implementation shapes
- **router**: task-shape selection and composition
- **evaluations**: executable evidence that an agent can apply the guidance

The new design skills are:

- ruby-poro
- ruby-service-objects
- ruby-domain-modeling
- ruby-dependency-injection
- ruby-object-composition

The design-pattern catalog includes service/application objects, commands, strategies, policies, adapters, dependency injection, null objects, factories, builders, decorators, facades, repositories, specifications, state objects, presenters, and the existing Rails and algorithm patterns.

The source books directly support service objects/POROs, responsibility boundaries, OOP, modules, refactoring, testing, and Rails application structure. Other pattern names are explicitly repository synthesis and should not be attributed to the books unless source evidence is added.

## Allerin training / assessment material

The assessment should be treated as an evaluation corpus.

Observed task families include:

- selection sort and recursive selection sort
- smallest missing number in a sorted array
- shopping cart domain behavior
- triplet sum with the stated O(n^2) / O(1) target
- majority element
- distinct elements from duplicates
- power-of-two detection with bitwise logic
- Chocolate Feast
- object-oriented design expectations across the programs

Do not turn these prompts into source-text skills. Turn them into testable evaluation cases that measure:

- functional correctness
- edge-case handling
- complexity adherence
- object-oriented design
- readability
- test quality

## Coverage states

- **covered** — a skill already provides actionable guidance.
- **partial** — the topic is mentioned but deserves dedicated routing or deeper procedure.
- **planned** — the topic has no dedicated skill yet.
- **eval-only** — the material is primarily a benchmark or exercise.

The goal is not to maximize skill count. The goal is to make routing precise while keeping each skill focused.

## rails_best_practices

The repository incorporates the documented review taxonomy from [flyerhzm/rails_best_practices](https://github.com/flyerhzm/rails_best_practices), a Rails code-metric tool. Its documented checks cover model responsibility, associations/query access, database indexes, RESTful routes, controller/view/helper boundaries, migrations, mailers, exception handling, and unused methods. citeturn0search0

| Source area | Agent coverage |
|---|---|
| Model/persistence checks | rails-best-practices, rails-activerecord, rails-associations, rails-validations |
| RESTful route checks | rails-best-practices, rails-routing |
| Controller boundary checks | rails-best-practices, rails-controllers, rails-architecture |
| View/helper checks | rails-best-practices, rails-views |
| Migration/index checks | rails-best-practices, rails-activerecord |
| Exception handling | rails-best-practices, ruby-debugging |
| Unused/dead-code review | rails-best-practices, ruby-clean-code |
| Analyzer finding interpretation | rails-best-practices, rails-best-practice-review |

Historical checks are treated as review signals. The agent must translate them to the actual Rails version and repository contract instead of introducing deprecated APIs merely to satisfy an old rule.
## RuboCop and plugin ecosystem

The repository now incorporates the current RuboCop plugin taxonomy from the official Plugins documentation. The current documentation page lists 11 official plugins and 7 third-party plugins, in addition to the core rubocop gem. The plugin system was introduced in RuboCop 1.72 and is the recommended extension-loading mechanism for compatible plugins.

Coverage is implemented through:

- skills/rubocop/SKILL.md — agent workflow and plugin selection
- data/rubocop/plugins.yml — machine-readable plugin catalog
- docs/RUBOCOP_PLUGINS.md — human-readable catalog
- patterns/ruby/rubocop-review.md — review procedure
- router integration in router/ROUTING.md

Source: https://docs.rubocop.org/rubocop/latest/plugins.html
## RSpec Style Guide

The repository now includes the RSpec Style Guide at https://rspec.rubystyle.guide/ as the style source for RSpec specifications. The guide assumes RSpec 3 or later and points to `rubocop-rspec` as the executable enforcement mechanism. citeturn198163view0

Coverage is implemented through:
- `skills/rubocop/SKILL.md` — RSpec-aware RuboCop workflow
- `.rubocop.yml` — explicit core RSpec style policies
- `docs/RSPEC_STYLE_GUIDE.md` — source-to-enforcement map
- `rubocop-rspec` — executable RSpec cop implementation

Key source areas include spec layout, example-group structure, subject/let/hooks, contexts, expectations, matchers, doubles, test isolation, naming, and controlled DRYing. The upstream guide explicitly treats itself as a living document, so agents must check installed RSpec/rubocop-rspec versions before assuming a rule is current. citeturn198163view0
## Runtime compatibility

The repository now includes `ruby-runtime-compatibility` as the runtime/version intelligence layer for AI coding agents. It separates concrete resolved versions, declared constraints, CI-supported matrices, tooling targets, and conflicting evidence.

Operational coverage:
- `skills/ruby-runtime-compatibility/SKILL.md` — decision rules and compatibility procedure
- `lib/ruby_agent_skills/runtime_profile.rb` — repository evidence detector
- `bin/runtime-profile` — JSON CLI output
- `docs/RUNTIME_PROFILE.md` — evidence model and agent workflow
- `test/runtime_profile_test.rb` — deterministic resolution/conflict tests

## Ruby concurrency

The concurrency layer adds:
- `skills/ruby-concurrency/SKILL.md` — workload classification, ownership, synchronization, lifecycle, failure propagation, Rails/database boundaries, Fibers, race/deadlock diagnosis, deterministic testing, and capacity-aware performance guidance.
- `patterns/ruby-design/bounded-concurrency.md` — bounded worker/queue implementation shape.
- `evals/concurrency/concurrency-counter.yml` — executable thread-safety contract.
- `scripts/verify_concurrency_eval.rb` — functional, contract, and test-change verification.

## Rails security

The security layer incorporates the Rails Security Guide and operational tooling for Brakeman and bundler-audit. citeturn429055view0turn429055search0turn290116search0

Coverage includes authentication, authorization, sessions, CSRF, XSS, SQL/query safety, command injection, redirects, file access, SSRF, security headers, secrets, webhooks, tenant isolation, dependency security, scanner interpretation, and abuse-case tests.

Operational artifacts:
- `skills/rails-security/SKILL.md`
- `patterns/rails/security-boundary-review.md`
- `data/security/tools.yml`
- `bin/security-audit`
- `docs/SECURITY.md`
- `evals/security/*`
- `scripts/verify_security_eval.rb`