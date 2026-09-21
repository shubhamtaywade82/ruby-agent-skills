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
| ruby-collections | Arrays, hashes and Enumerable |\n| ruby-blocks-procs-lambdas | Blocks, Proc, lambda and callback semantics |\n| ruby-enumerables | Enumerable decision rules and pipeline design |\n| ruby-api-design | Public method/library contracts |
| ruby-poro | Plain Ruby object boundaries |
| ruby-service-objects | Focused application workflows |
| ruby-domain-modeling | Business concepts and invariant ownership |
| ruby-dependency-injection | Explicit replaceable collaborators |
| ruby-object-composition | Composition and inheritance decisions |\n| ruby-boolean-logic | Predicates, truthiness and conditional design |
| ruby-method-design | Method responsibility and contracts |
| ruby-oop | Classes, encapsulation, inheritance, composition |
| ruby-modules-mixins | Modules, mixins and namespaces |
| ruby-metaprogramming | Reflection and runtime behavior |
| ruby-gems-io-services | Dependencies, I/O, HTTP and service boundaries |
| ruby-debugging | Evidence-driven debugging |
| ruby-runtime-compatibility | Ruby/Rails/Bundler version and compatibility resolution |
| ruby-concurrency | Threads, queues, synchronization, lifecycle, Fibers and concurrency hazards |
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
| rails-best-practices | Rails quality review and RailsBestPractices interpretation |
| rails-security | Rails application security and security-tool interpretation |
| rails-test-engineering | Test-boundary selection, deterministic async tests, parallel safety, flaky-test diagnosis, system tests, CI, and test performance |
| rails-production-runtime | Puma, process lifecycle, graceful shutdown, release ordering, Solid Queue runtime, secrets, and production capacity |
| rails-database-engineering | Production migrations, indexes, constraints, transactions, locking, backfills, query plans, and connection pools |
| rails-observability | Rails request lifecycle, error reporting, request correlation, instrumentation, and health semantics |
| rails-active-job | Active Job lifecycle, retries, idempotency, queues, transactions, and Solid Queue semantics |
| rails-zeitwerk | Zeitwerk path/constant, namespace, reload, and eager-load correctness |
| ruby-performance | Evidence-driven Ruby/Rails benchmarking, profiling, caching, and optimization |
| rubocop | Ruby/Rails style analysis and RuboCop plugin selection |

## Runtime intelligence

The repository now includes an executable runtime profile detector:

    ruby bin/runtime-profile /path/to/app

It reports Ruby, Rails, Bundler and CI version evidence while distinguishing resolved versions, constraints and conflicts. The agent must use that evidence before version-sensitive implementation or upgrades.

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

The source set includes *The Ruby Workshop*, *Clean Ruby*, and the uploaded *Learn Rails 6* material.

The Ruby Workshop covers Ruby programs, data types, program flow, methods, OOP, modules/mixins, gems and I/O, debugging, metaprogramming, HTTP and Rails topics including MVC, routes, forms, Active Record, authentication, associations, validations, scaffolding and hosting.

Clean Ruby focuses on readable, changeable and straightforward code, then develops naming, method design, boolean logic, classes, refactoring and TDD.

The Allerin assessment is treated as an evaluation source rather than copied into the skills. Its tasks include sorting, missing values, shopping-cart behavior, triplet sum, majority element, distinct values, power-of-two detection and Chocolate Feast, with an explicit OOP requirement.

The repository does not reproduce the books. It turns their ideas into operational instructions for agents and uses the assessment plus book-derived exercises as benchmark corpora.

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
├── data/
│   └── rubocop/
│       └── plugins.yml
├── .rubocop.yml
└── skill-manifest.yml
```

## Implementation patterns

Patterns are concrete, reusable implementation shapes selected after skills classify a task.

Current families include:

| Family | Examples |
|---|---|
| Ruby design | value object, service object, application service, command, strategy, policy, composition, adapter, dependency injection, null object, factory, builder, decorator, facade, repository, specification, state object, external API client, gem boundary |
| Rails | query object, form object, policy boundary, transaction boundary, request flow, REST resource, scaffold lifecycle, presenter |
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


## Phase 9 real agent adapter

The repository now includes a provider-neutral command adapter:

    ruby bin/agent-benchmark --command 'YOUR_AGENT_COMMAND'

It keeps the same agent command/model configuration across baseline and skills-enabled paired runs while changing only the materialized skill context. Provider-specific credentials and launch logic stay outside the repository.

## Book Integration v2

The second book integration adds focused Ruby/Rails skills, a design-pattern catalog, and an eight-case Ruby/Rails evaluation family under evals/ruby-workshop. The cases cover Enumerable selection, public API contracts, voting/application design, service objects, external API boundaries, gem packaging, REST resources, and authentication boundaries.


## Design skill system

The repository now has a dedicated design layer for POROs, service objects, domain modeling, dependency injection, and object composition.

Design patterns are deliberately separate from skills. The router selects a skill first, then considers the smallest justified pattern. Pattern selection includes negative cases so agents are trained not to introduce abstractions merely because a pattern exists.

The design layer currently covers:

- PORO boundaries
- service/application objects
- command objects
- value objects
- strategies and policies
- adapters and external API clients
- dependency injection
- composition over inheritance
- null objects
- factories and builders
- decorators and facades
- repositories and specifications
- state objects
- Rails query/form/policy/transaction/request patterns
- presenters


## Phase 9.5B — Design pattern evaluation corpus

The repository now includes a dedicated design-pattern benchmark family with 18 public evaluation cases. It measures functional correctness, test execution, public contracts, pattern selection, and scope control.

The corpus explicitly includes pattern-restraint cases so agents are evaluated on choosing when not to introduce an abstraction.

Run the design-pattern campaign with:

    ruby bin/benchmark campaign \
      --manifest benchmarks/design-patterns/campaign.yml \
      --agent-command 'AGENT_COMMAND'


## Concurrency engineering

The repository includes a dedicated `ruby-concurrency` skill and bounded-concurrency pattern. Its benchmark layer verifies synchronized shared state, tests, and explicit concurrency contracts. The guidance treats Ruby threads, Rails executors/jobs, database connection pools, process boundaries, and Fibers as distinct concerns rather than one generic "parallelism" abstraction.


## Security engineering

The repository now includes a Rails security skill, a security-boundary review pattern, a machine-readable security tool registry, a security audit CLI, and a public security evaluation family.

Use:

    ruby bin/security-audit /path/to/rails-app

Security tooling is treated as evidence and must be interpreted against the actual trust boundary and data flow.


## Performance engineering

Performance guidance is evidence-driven: establish a workload and baseline, measure, identify the bottleneck, make the smallest targeted change, and re-measure.

The repository includes profiling/benchmark tool metadata, performance-specific patterns, and executable performance evaluations. It explicitly distinguishes latency, throughput, CPU, allocations, GC, database time, network time, and cache correctness.


## Zeitwerk and autoloading

The repository includes a dedicated Rails Zeitwerk skill, structure-review pattern, loader tooling registry, verification CLI, and executable evaluations.

For a Rails project:

    ruby bin/zeitwerk-check /path/to/rails-app

The agent is expected to resolve path-to-constant mappings and loader lifecycle before adding manual require workarounds.


## Active Job engineering

The repository includes a dedicated Active Job/Solid Queue skill, four job-design patterns, tool metadata, and a public background-job benchmark family.

Coverage includes:

- idempotent side effects
- retry/discard classification
- transaction-aware enqueueing
- queue/priority decisions
- concurrency controls
- recurring/scheduled execution
- serialization and GlobalID
- shutdown/recovery
- job observability and testing

Run the benchmark campaign with:

    ruby bin/benchmark campaign \
      --manifest benchmarks/active-job/campaign.yml \
      --agent-command 'AGENT_COMMAND'


## Rails observability

The repository includes a dedicated request lifecycle and observability layer covering:

- stable API error contracts
- Rails.error reporting
- request IDs and correlation
- structured/tagged logging
- sensitive parameter filtering
- ActiveSupport::Notifications
- request metrics
- health/liveness/readiness semantics
- middleware and production debugging

Run the benchmark campaign with:

    ruby bin/benchmark campaign \
      --manifest benchmarks/observability/campaign.yml \
      --agent-command 'AGENT_COMMAND'


## Rails database engineering

The repository includes a production database engineering layer covering:

- zero-downtime / expand-contract schema changes
- production index strategy
- database constraints
- bounded data backfills
- transaction and lock boundaries
- isolation and deadlock reasoning
- query-plan verification
- connection-pool capacity
- bulk write semantics
- multi-database and role considerations

Run the benchmark campaign with:

    ruby bin/benchmark campaign \
      --manifest benchmarks/database-engineering/campaign.yml \
      --agent-command 'AGENT_COMMAND'


## Rails production runtime

The repository includes a production-runtime engineering layer covering:

- Puma worker/thread capacity
- database/process resource budgets
- boot and preload behavior
- hot/phased restart semantics
- graceful shutdown
- Solid Queue process topology
- container/process-manager lifecycle
- readiness gates
- runtime secret/configuration contracts
- zero-downtime release ordering
- rollback boundaries

Run the benchmark campaign with:

    ruby bin/benchmark campaign \
      --manifest benchmarks/production-runtime/campaign.yml \
      --agent-command 'AGENT_COMMAND'


## Rails test engineering

The repository now includes a staff-level Rails test engineering layer covering:

- test-boundary selection
- request/integration/system testing
- Active Job testing
- deterministic async tests
- database isolation
- parallel-test safety
- flaky-test diagnosis
- test-suite performance
- CI/system-test/eager-load verification
- focused external-boundary doubles

Run the benchmark campaign with:

    ruby bin/benchmark campaign \
      --manifest benchmarks/test-engineering/campaign.yml \
      --agent-command 'AGENT_COMMAND'

## Rails caching engineering

The repository now includes a dedicated rails-caching layer for cache correctness and systems behavior. It covers cache-key identity, freshness, invalidation ownership, versioning across releases, stampede control, warming, cache-store failure behavior, capacity/eviction, security isolation, and deterministic cache-contract testing.

Core patterns:
- cache-boundary
- cache-key-isolation
- cache-invalidation-contract
- cache-stampede-control
- cache-failure-boundary
- cache-warming-strategy
- cache-capacity-review

The cache layer composes with rails-performance, rails-observability, rails-security, rails-database-engineering, and rails-active-job.
## Rails Action Mailer engineering

The repository now includes a dedicated `rails-action-mailer` layer covering mailer contracts, synchronous versus asynchronous delivery, transaction semantics, duplicate/uncertain delivery, provider boundaries, SMTP configuration, email security/privacy, previews, observability, and deterministic testing.

Core patterns:
- `mailer-contract`
- `mailer-delivery-semantics`
- `mailer-provider-boundary`
- `mailer-security-boundary`
- `mailer-testing`
- `mailer-observability`
## Rails Active Storage engineering

The repository now includes a dedicated `rails-active-storage` layer for attachment ownership, upload security, direct uploads, storage services, private/public file access, variants and previews, analysis, purge/reconciliation, storage migration/mirroring, and deterministic testing.

Core patterns:
- `active-storage-boundary`
- `active-storage-upload-security`
- `active-storage-direct-upload`
- `active-storage-serving`
- `active-storage-processing`
- `active-storage-purge`
- `active-storage-testing`
## Rails Action Cable & realtime engineering

The repository now includes a dedicated `rails-action-cable` layer for WebSocket connection authentication, channel authorization, stream naming, broadcast contracts, reconnect/reconciliation, realtime capacity, failure/degradation semantics, and deterministic testing.

Core patterns:
- `action-cable-connection-auth`
- `action-cable-channel-authorization`
- `action-cable-stream-contract`
- `action-cable-broadcast-contract`
- `action-cable-reconciliation`
- `action-cable-capacity`
- `action-cable-failure-boundary`
- `action-cable-testing`
## Rails I18n & localization engineering

The repository now includes a dedicated `rails-i18n` layer for locale resolution, translation-key contracts, pluralization and formatting, localized routing, background locale propagation, locale-aware caching, localization security, and deterministic tests.

Core patterns:
- `i18n-locale-resolution`
- `i18n-translation-key-contract`
- `i18n-pluralization-formatting`
- `i18n-localized-routing`
- `i18n-context-propagation`
- `i18n-cache-identity`
- `i18n-security-boundary`
- `i18n-testing`
## Rails Action Text engineering

The repository now includes a dedicated `rails-action-text` layer for rich-text ownership, sanitization, embedded attachment/attachable authorization, rendering, API representation, RichText/embed performance, lifecycle coordination, and deterministic testing.

Core patterns:
- `action-text-content-contract`
- `action-text-sanitization-security`
- `action-text-attachment-authorization`
- `action-text-rendering`
- `action-text-api-boundary`
- `action-text-preload-performance`
- `action-text-lifecycle`
- `action-text-attachable-contract`
- `action-text-testing`

## Rails framework boundary coverage

The Rails integration layer now includes focused skills for framework boundaries that commonly cross trust, persistence, asynchronous execution, and external-provider concerns:

- rails-action-view — Action View rendering, partial/layout/helper contracts, strict locals, output safety, localized templates, and rendering performance;
- rails-active-model — Active Model model protocol, transient attributes, validations, conversion, dirty state, callbacks, serialization, translation, and linting;
- rails-action-mailer — outbound email content, delivery, provider, security, and observability;
- rails-action-mailbox — inbound email ingress, routing, sender/tenant authorization, idempotency, failure/quarantine, retention, and deterministic testing;
- rails-active-storage — uploaded-file ownership, storage, access, processing, purge, and testing;
- rails-action-cable — realtime connection/channel authorization, stream contracts, reconciliation, and capacity;
- rails-i18n — locale context, translation contracts, formatting, routing, propagation, caching, security, and testing;
- rails-action-text — rich content, sanitization, attachables, rendering, API boundaries, lifecycle, performance, and testing.

These boundaries are compositional. The router should select Action Mailbox for inbound email mechanics, then compose security, Active Job, Active Storage, database, reliability, observability, and test-engineering skills where the task requires them.
