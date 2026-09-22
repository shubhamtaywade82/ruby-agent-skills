# Ruby Agent Skills

A repository of **agent-executable Ruby and Ruby on Rails engineering knowledge**.

The goal is not to store passive notes. The repository turns engineering material into a system an AI coding agent can use to **classify a task, inspect a repository, select skills and patterns, implement a bounded change, verify behavior, and report evidence**.

> **Current milestone:** Iteration 66 — External Routing Campaign Handoff  
> **Branch:** `feat/routing-campaign-preflight-v1`

---

## What this repository contains

The skill system is built from five connected layers:

```text
                         ┌──────────────────────┐
                         │       Task           │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │ Runtime / Repository │
                         │      Inspection      │
                         └──────────┬───────────┘
                                    │
                                    ▼
                    ┌──────────────────────────────┐
                    │      Skill Router            │
                    │ skill-manifest + ROUTING.md  │
                    └──────────────┬───────────────┘
                                   │
                     ┌─────────────┴─────────────┐
                     ▼                           ▼
              ┌─────────────┐             ┌─────────────┐
              │   Skills    │             │  Patterns   │
              │   What/Why  │             │  How/When   │
              └──────┬──────┘             └──────┬──────┘
                     └─────────────┬─────────────┘
                                   ▼
                         ┌──────────────────────┐
                         │ Implementation +     │
                         │ Focused Verification │
                         └──────────┬───────────┘
                                    ▼
                         ┌──────────────────────┐
                         │ Evaluations / System │
                         │ Tests / CI Evidence  │
                         └──────────────────────┘
```

### Current validated inventory

| Capability | Count |
|---|---:|
| Skills | **76** |
| Implementation patterns | **393** |
| Evaluation cases | **392** |
| Dedicated system/contract tests | **52** |
| Manifest version | **2** |

The exact inventory is governed by `skill-manifest.yml`; `bin/validate` is the source of truth for library-contract validation.

---

# Skill coverage

## Ruby fundamentals

The Ruby foundation covers:

- language semantics and object model
- core data types
- control flow
- collections and Enumerable
- blocks, Proc, lambda, and callbacks
- API and method design
- OOP and encapsulation
- modules and mixins
- metaprogramming
- PORO boundaries
- service/application objects
- domain modeling
- dependency injection
- object composition
- boolean/predicate design
- gems, I/O, HTTP, and external service boundaries
- debugging
- clean code
- TDD and refactoring
- runtime/version compatibility
- concurrency
- performance
- RuboCop

Core skills include:

`ruby-core` · `ruby-data-types` · `ruby-control-flow` · `ruby-collections` · `ruby-blocks-procs-lambdas` · `ruby-enumerables` · `ruby-api-design` · `ruby-method-design` · `ruby-oop` · `ruby-modules-mixins` · `ruby-metaprogramming` · `ruby-poro` · `ruby-service-objects` · `ruby-domain-modeling` · `ruby-dependency-injection` · `ruby-object-composition` · `ruby-boolean-logic` · `ruby-gems-io-services` · `ruby-debugging` · `ruby-clean-code` · `ruby-tdd-refactoring` · `ruby-concurrency` · `ruby-performance` · `ruby-runtime-compatibility`

---

# Rails framework coverage

The Rails layer has both foundational skills and deep framework-boundary skills.

## Core Rails

- `rails-architecture`
- `rails-routing`
- `rails-controllers`
- `rails-action-controller`
- `rails-views`
- `rails-activerecord`
- `rails-active-record`
- `rails-associations`
- `rails-validations`
- `rails-authentication`
- `rails-testing`
- `rails-generators`
- `rails-deployment`
- `rails-best-practices`
- `rails-security`

## Deep framework engineering

The repository now has dedicated deep skills for:

- **Action Controller** — request/response boundaries, strong parameters, sessions/cookies, callbacks, negotiation, conditional responses, streaming/downloads, exception mapping.
- **Active Record** — Relation semantics, query composition, scopes, persistence lifecycle, callbacks, bulk operations, loading, deletion, strict loading.
- **Associations** — cardinality, inverse behavior, through associations, polymorphic boundaries, dependent lifecycle, autosave, counters/touch, callbacks, loading.
- **Validations** — lifecycle, contexts, conditions, errors, custom validators, strict failures, associated validation, uniqueness/database enforcement, bypass paths.
- **Action View** — rendering, partials, strict locals, layouts, helpers, output safety, localization, caching, rendering performance.
- **Active Model** — model protocol, transient attributes, validations, conversion, dirty state, callbacks, serialization, translation, linting.
- **Active Support** — loading, Concern, class configuration, CurrentAttributes, callbacks, instrumentation, time semantics, inflection.
- **Action Mailer** — mailer contracts, delivery semantics, providers, security/privacy, previews, observability, deterministic tests.
- **Action Mailbox** — inbound email ingress, routing, sender/tenant authorization, idempotency, quarantine, replay, retention.
- **Active Storage** — attachment ownership, direct uploads, storage services, private/public serving, processing, purge, migration/mirroring.
- **Action Cable** — WebSocket authentication/authorization, streams, broadcasts, reconciliation, capacity, failure boundaries.
- **I18n** — locale resolution, translation contracts, formatting, localized routing, propagation, cache identity, security.
- **Action Text** — rich text ownership, sanitization, attachables, rendering, API boundaries, lifecycle, performance.
- **Zeitwerk** — autoloading, eager loading, reloading, path/constant contracts.
- **Active Job** — lifecycle, retries, idempotency, transactions, queues, concurrency, recurring execution, serialization, observability.
- **API Integration** — API contracts, versioning, external HTTP clients, retries/timeouts, webhooks, idempotency, compatibility.
- **Caching** — key identity, invalidation, freshness, stampede control, warming, failure boundaries, capacity.
- **Database Engineering** — migrations, constraints, indexes, backfills, transactions, locking, query plans, connection pools, multi-database roles.
- **Performance** — profiling, workload baselines, N+1, query plans, allocations, caching, Puma capacity, job throughput.
- **Observability** — request lifecycle, errors, correlation, instrumentation, structured logging, metrics, health semantics.
- **Production Runtime** — Puma, process lifecycle, shutdown, boot, Solid Queue topology, readiness, secrets, release ordering.
- **Reliability** — SLO/error budgets, dependency failure, circuit breakers, bulkheads, load shedding, degradation, recovery objectives, resilience testing.
- **Distributed Systems** — service boundaries, message delivery, outbox/inbox, deduplication, sagas, distributed locks, eventual consistency.
- **Event-Driven Messaging** — events, commands, brokers, schemas, acknowledgements, replay, DLQs, consumer lag, capacity.
- **Release Engineering** — artifact promotion, deployment gates, progressive delivery, canary/staged rollout, rollback/roll-forward, release evidence.
- **Incident Engineering** — incident triage, runbooks, diagnostics, mitigation, recovery verification, post-incident review.
- **Security Engineering** — threat modeling, trust boundaries, tenant isolation, secret management, SSRF/network security, supply chain and residual risk.
- **Test Engineering** — boundary selection, deterministic async tests, database isolation, parallel safety, flaky-test diagnosis, CI/system-test verification.

---

# Rails Routing Engineering

The latest milestone deepened the foundational `rails-routing` skill into a full routing engineering layer.

### Coverage

- route precedence and shadowing
- resource design
- nested and shallow resources
- namespaces and scopes
- segment/request/host/subdomain/format constraints
- route helper and URL-generation contracts
- polymorphic routing
- routing concerns
- `direct` and `resolve`
- wildcard/catch-all routes
- redirects
- Rack and engine mounts
- API/version/format routing
- localized and host-aware routing
- route-table inspection
- route-generation/recognition testing

### Routing patterns

- `route-precedence-contract`
- `nested-route-boundary`
- `route-scope-namespace-contract`
- `route-constraint-contract`
- `route-helper-contract`
- `route-concern-contract`
- `direct-route-resolution`
- `mounted-endpoint-boundary`
- `catch-all-route-boundary`
- `route-testing`

The routing layer deliberately keeps **dispatch and URL generation separate from authorization and business invariants**.

---


---

# Rails Authentication Engineering

The current milestone deepens authentication from a shallow sign-in/sign-out reference into a lifecycle and security boundary.

### Coverage

- authentication mechanism discovery, including Rails 8+ generated authentication
- credential hashing/storage and secret-safe logging
- explicit authentication state transitions
- session lifecycle, fixation resistance, renewal, expiry, and logout
- current-session, per-device, global, and compromise-driven revocation
- password reset/recovery with expiry, replay prevention, and enumeration-safe behavior
- credential-stuffing, brute-force, reset-abuse, and throttling controls
- remember-me and persistent-login semantics
- browser session versus API/token authentication boundaries
- actor/tenant context propagation without serializing credentials
- recent/fresh authentication requirements for sensitive operations
- transition-focused request/system/security regression tests

### Authentication artifacts

- `skills/rails-authentication/SKILL.md`
- `patterns/rails/authentication-mechanism-boundary.md`
- `patterns/rails/credential-storage-contract.md`
- `patterns/rails/session-lifecycle-contract.md`
- `patterns/rails/session-fixation-rotation.md`
- `patterns/rails/session-revocation-contract.md`
- `patterns/rails/password-recovery-contract.md`
- `patterns/rails/login-abuse-controls.md`
- `patterns/rails/remember-me-contract.md`
- `patterns/rails/browser-api-auth-boundary.md`
- `patterns/rails/authentication-context-propagation.md`
- `patterns/rails/authentication-freshness-boundary.md`
- `patterns/testing/authentication-testing.md`
- `evals/rails/authentication-contract.yml`
- `test/rails_authentication_system_test.rb`

Primary source: https://guides.rubyonrails.org/security.html

The boundary is intentionally compositional: security engineering owns threat/trust analysis, authorization owns action/resource permission, API integration owns external credential contracts, and Active Job/Action Cable own their execution boundaries.

## Rails Asset and Build Infrastructure Engineering

The current milestone deepens Rails frontend infrastructure into an explicit build/runtime boundary covering asset strategy selection, Importmap, JavaScript and CSS bundling, development process orchestration, dependency/runtime contracts, reproducibility, production parity, artifact/cache identity, supply-chain security, and release verification.

Artifacts:

- `skills/rails-asset-build-engineering/SKILL.md`
- `patterns/rails/rails-asset-pipeline-contract.md`
- `patterns/rails/importmap-contract.md`
- `patterns/rails/jsbundling-contract.md`
- `patterns/rails/cssbundling-contract.md`
- `patterns/rails/bin-dev-process-contract.md`
- `patterns/rails/asset-build-reproducibility.md`
- `patterns/rails/asset-build-production-parity.md`
- `patterns/rails/asset-dependency-boundary.md`
- `patterns/testing/asset-build-testing.md`
- `evals/rails/asset-build-contract.yml`
- `test/rails_asset_build_system_test.rb`


## Rails Rack / Middleware Engineering

The current milestone deepens the Rails request boundary into explicit Rack/middleware engineering coverage.

### Coverage

- Rack request/response and environment contracts
- middleware stack ordering and environment-specific composition
- custom middleware responsibility boundaries
- short-circuit responses and downstream execution
- exception propagation and error ownership
- request-ID/correlation and middleware observability
- trusted proxy and forwarded-header security
- transport/security middleware boundaries
- request-level rate limiting and deployment topology
- thread/fiber/process safety and middleware lifecycle
- hot-path performance and capacity considerations
- deterministic Rack, integration, and stack tests

### Rack/middleware artifacts

- `skills/rails-rack-middleware-engineering/SKILL.md`
- `patterns/rails/rack-request-response-contract.md`
- `patterns/rails/middleware-stack-ordering.md`
- `patterns/rails/custom-rack-middleware-contract.md`
- `patterns/rails/middleware-short-circuit-contract.md`
- `patterns/rails/middleware-exception-propagation.md`
- `patterns/rails/middleware-thread-safety.md`
- `patterns/rails/request-id-correlation-boundary.md`
- `patterns/rails/middleware-security-boundary.md`
- `patterns/rails/middleware-rate-limit-boundary.md`
- `patterns/rails/trusted-proxy-header-contract.md`
- `patterns/rails/middleware-observability-boundary.md`
- `patterns/rails/middleware-testing.md`
- `evals/rails/rack-middleware-contract.yml`
- `test/rails_rack_middleware_system_test.rb`

# Agent operating model

The agent is expected to follow this workflow:

```text
Task
  │
  ▼
Classify
  │
  ▼
Resolve Ruby / Rails / dependency versions
  │
  ▼
Inspect repository and existing conventions
  │
  ▼
Route to skills
  │
  ▼
Select the smallest justified patterns
  │
  ▼
Implement the smallest coherent change
  │
  ▼
Run focused verification
  │
  ▼
Run regression / system verification
  │
  ▼
Review diff and failure evidence
  │
  ▼
Report facts, changes, and verification
```

The core principles are:

- evidence over assumptions
- repository conventions over invented conventions
- version-aware implementation
- explicit behavior over unnecessary abstraction
- tests as executable contracts
- small, reviewable changes
- deterministic verification
- no claims of correctness without evidence

---

# Skill routing

The routing contract is defined in:

- `skill-manifest.yml`
- `router/ROUTING.md`
- `AGENTS.md`

The manifest provides machine-readable:

- skill identity
- family
- activation triggers
- implementation pattern paths
- evaluation registration
- default workflow requirements

The router provides cross-skill composition rules.

`AGENTS.md` provides repository-level operating instructions for implementation agents.

---

# Implementation patterns

Patterns are concrete implementation shapes selected **after** the relevant skill has classified the problem.

Current pattern families include:

### Ruby design

Value objects, service/application objects, commands, strategies, policies, composition, adapters, dependency injection, null objects, factories, builders, decorators, facades, repositories, specifications, state objects, external API clients, and gem boundaries.

### Rails

Query objects, form objects, policy boundaries, transaction boundaries, request-flow patterns, REST resources, scaffolding, presenters, and the deep framework patterns listed above.

### Testing

Regression testing, deterministic boundary testing, routing testing, and framework-specific testing contracts.

### Algorithms

Two pointers, frequency maps, and the original Ruby training algorithm corpus.

Patterns include negative guidance. The existence of a pattern is **not** a reason to introduce it.

---

# Evaluation system

Evaluations are machine-readable task contracts.

Each evaluation can specify:

- functional behavior
- explicit implementation constraints
- public contracts
- design requirements
- test requirements
- scope control
- expected failure modes

Current validated evaluation inventory: **392 cases**.

Important evaluation families include:

- Ruby training
- Ruby Workshop integration
- design patterns
- concurrency
- security
- observability
- database engineering
- production runtime
- Active Job
- test engineering
- Rails framework boundaries
- Rails API/integration
- reliability
- distributed systems
- event-driven messaging
- release engineering
- incident engineering
- caching
- Action Mailer
- Active Storage
- Action Cable
- I18n
- Action Text
- Action Mailbox
- Action View
- Active Model
- Active Support
- Action Controller
- Active Record
- Associations
- Validations
- Routing

---

# Benchmark infrastructure

The repository includes a provider-neutral benchmark system.

List evaluations:

```bash
ruby bin/eval list
```

Inspect an evaluation:

```bash
ruby bin/eval show EVAL_ID
```

Build an evaluation packet:

```bash
ruby bin/eval packet EVAL_ID
```

Run an evaluation with an external agent:

```bash
ruby bin/eval run EVAL_ID \
  --workspace /tmp/eval-workspace \
  --agent-command 'AGENT_COMMAND' \
  --verify-command 'VERIFY_COMMAND'
```

Run a campaign:

```bash
ruby bin/benchmark campaign \
  --manifest benchmarks/<family>/campaign.yml \
  --agent-command 'AGENT_COMMAND'
```

The benchmark system keeps provider credentials and launch-specific configuration outside the repository.

---

# Runtime intelligence

Before version-sensitive work, use:

```bash
ruby bin/runtime-profile /path/to/app
```

This resolves and reports Ruby, Rails, Bundler, and CI evidence while distinguishing:

- resolved versions
- declared constraints
- conflicts
- runtime evidence

Agents should not guess Rails behavior when the repository can provide the version evidence.

---

# Repository validation

The repository has one integrated validation entry point:

```bash
bin/validate
```

Validation covers:

- skill contracts
- pattern contracts
- evaluation contracts
- runtime/security/loader/observability/database/production/test-engineering system checks
- manifest consistency
- routing/activation contracts
- adversarial routing quality contracts
- benchmark fixture consistency

The validation suite currently reports:

```text
76 skills
393 implementation patterns
392 evaluation cases
```

---

# Repository structure

```text
ruby-agent-skills/
├── skills/                    # agent skills
├── patterns/                  # reusable implementation patterns
│   ├── ruby-design/
│   ├── rails/
│   ├── testing/
│   └── algorithms/
├── router/
│   ├── ROUTING.md             # cross-skill routing rules
│   └── ROUTING_CASES.yml      # adversarial routing contracts
├── docs/
│   ├── SKILL_CONTRACT.md
│   ├── PATTERN_SCHEMA.md
│   ├── EVAL_SCHEMA.md
│   ├── SOURCE_COVERAGE.md
│   └── benchmark/...
├── evals/
│   ├── schema/
│   ├── ruby-training/
│   ├── ruby-workshop/
│   ├── design-patterns/
│   ├── rails/
│   └── ...
├── benchmarks/
│   └── ...                    # campaign manifests and fixtures
├── data/
│   └── rubocop/
├── bin/
│   ├── validate
│   ├── eval
│   ├── benchmark
│   ├── agent-benchmark
│   ├── runtime-profile
│   └── ...
├── AGENTS.md
├── skill-manifest.yml
└── README.md
```

---

# Source foundation

The repository began from Ruby/Rails training material and has progressively converted that material into executable agent knowledge.

Source categories include:

- Ruby Workshop material
- Clean Ruby material
- Learn Rails 6 material
- Allerin assessment material as an evaluation/benchmark source
- current Rails framework documentation for version-sensitive framework boundaries

The repository does **not** reproduce source books. It operationalizes their engineering ideas into skills, patterns, evaluations, and verification contracts.

See:

- `docs/SOURCE_COVERAGE.md`
- `docs/SKILL_CONTRACT.md`
- `docs/PATTERN_SCHEMA.md`
- `docs/EVAL_SCHEMA.md`

---

# Development status

The repository is being expanded iteratively rather than treated as a static documentation dump.

Completed deep Rails areas currently include:

- Action Controller
- Active Record
- Associations
- Validations
- Action View
- Active Model
- Active Support
- Action Mailer
- Action Mailbox
- Active Storage
- Action Cable
- I18n
- Action Text
- Routing
- API/integration
- Database engineering
- Production runtime
- Observability
- Active Job
- Performance
- Caching
- Reliability
- Distributed systems
- Event-driven messaging
- Release engineering
- Incident engineering
- Security engineering
- Test engineering
- Authentication engineering
- Authorization engineering
- Hotwire engineering

Authentication Engineering is now a deep Rails boundary covering mechanism discovery, credential storage, authentication state transitions, session lifecycle, fixation/rotation, expiry/revocation, password recovery, abuse controls, persistent login, browser/API boundaries, context propagation, freshness, multi-device sessions, compromise response, observability, and deterministic security testing.

The deep Rails framework sequence through Iteration 45 is complete; Iteration 46 audits repository-wide completeness and framework drift before evaluation hardening and release readiness.

---

# Contributing / extending the system

When adding a new skill or deepening an existing one:

1. inspect the current repository and manifest;
2. identify overlap with existing skills and patterns;
3. write the skill with activation, repository inspection, implementation/review guidance, verification, and source foundation;
4. add reusable patterns only where they represent repeatable engineering decisions;
5. add deterministic evaluation cases;
6. add a dedicated system/contract test where the skill has integration requirements;
7. register the skill/patterns/evaluation in the manifest;
8. update routing and `AGENTS.md`;
9. update this README when user-facing capability or architecture changes;
10. run `bin/validate`;
11. verify CI before reporting completion.

---

# Current milestone

**Iteration 55 — Real Agent Routing Campaign**

Latest implementation removes the Node 20 checkout warning, standardizes CI on the Node 24-compatible `actions/checkout@v7` line, and makes CI toolchain compatibility an executable repository contract.


## Rails Encryption and Credentials Engineering

Iteration 41 adds explicit contracts for Rails encrypted credentials, master-key delivery, environment-specific credential selection, secret redaction, Active Record Encryption, deterministic encrypted queries, storage sizing, encrypted-data migration, key rotation, and synthetic-secret testing.


## Rails Serialization and Global IDs Engineering

Iteration 42 adds explicit contracts for Rails serialization ownership, JSON representation, nested payloads, sensitive-field exclusion, serialized payload compatibility, Global ID identity, Signed Global ID integrity, locator restrictions, resolution failures, Active Job arguments, and custom serializers.

 
## Rails Operational Tasks and Maintenance

Iteration 43 adds executable contracts for custom Rake tasks, runner workflows, maintenance and cleanup, environment gates, dry-runs, idempotency, batching/checkpointing, locking, invariant preservation, partial failures, operational observability, scheduler overlap, data-repair verification, and production runbooks.


## Rails Cross-Boundary Authorization and Security Composition

Iteration 44 adds explicit security composition contracts across controllers, services, jobs, APIs, realtime channels, engines, operational commands, asynchronous event consumers, capabilities, denial semantics, authorization caches, and audit boundaries.


## Rails Staff and Principal Architecture

Iteration 45 adds a staff/principal decision layer for dependency direction, bounded contexts, modular monoliths, data ownership, shared kernels, cross-cutting ownership, change coupling, process-extraction readiness, incremental architecture migration, ADRs, executable architecture fitness checks, system tradeoffs, and operational ownership.


## Repository-wide Completeness and Gap Audit

Iteration 46 adds repository-level completeness enforcement for manifest registration, pattern/evaluation registration, routing coverage, system-test execution, README inventory drift, and current Rails framework evolution. Rails 8/8.1 additions are routed to their existing owning skills rather than fragmented into duplicate skill boundaries.


## Evaluation and Benchmark Hardening

Iteration 47 hardens the benchmark system with fixture-seam validation, controlled campaign requirements, public/hidden coverage disclosure, and campaign provenance preserved in campaign results. Public evaluation families without campaigns are reported explicitly rather than being treated as measured benchmark evidence.


## Rails Benchmark Coverage Expansion

Iteration 49 started measured benchmark coverage for the deep Rails evaluation corpus. The public campaign established paired baseline/skills-enabled execution, deterministic fixtures, independent verification, and explicit coverage disclosure.

## Iteration 48 — Final Release and Public-Readiness Hardening

Iteration 48 adds public contribution and security entry points, a changelog baseline, and an executable release-readiness audit covering required publication metadata, stale inventory/release markers, and generated benchmark artifacts.

## CI Toolchain and Release-Guard Maintenance

Iteration 52 removes the Node 20 checkout warning from CI, standardizes the repository on Node 24-compatible `actions/checkout@v7`, adds an executable CI toolchain audit, and makes the maintenance contract part of `bin/validate`.


## Rails Security and Identity Benchmark Expansion

Iteration 50 expanded the Rails benchmark campaign with five high-risk identity/security boundaries: `authentication-contract`, `authorization-contract`, `rails-cross-boundary-authorization-security-contract`, `rails-encryption-credentials-contract`, and `rails-serialization-globalid-contract`. These fixtures exercise identity lifecycle, tenant/resource authorization, delayed execution, secret/encryption boundaries, representation allowlists, Global ID integrity, and signed-identifier verification.


## Rails Benchmark Coverage Completion

Iteration 51 completes the public Rails benchmark campaign. All **27** Rails evaluation families now have disposable implementation/test seams and are registered in the controlled benchmarks/rails/campaign.yml. The campaign enforces paired execution, three repetitions, fresh workspaces, shared fixtures for baseline/skills-enabled comparisons, and explicit hidden-case disclosure.

The benchmark-quality audit now treats missing public Rails coverage as an error rather than a warning.

## Iteration 53 — Skill Routing and Activation Quality

Iteration 53 added adversarial routing cases for overlap-heavy tasks and made primary/secondary skill ownership an explicit repository contract.

## Iteration 54 — Empirical Skill Routing Evaluation

Iteration 54 added a provider-neutral routing evaluator that measures actual primary-skill selection and secondary-skill recall.

## Iteration 55 — Real Agent Routing Campaign

Iteration 55 turns the evaluator into a repeated campaign: three fresh repetitions per public routing case, campaign-level completion checks, and an expected-primary versus observed-primary confusion matrix. The repository now has a measurement path for discovering real cross-boundary routing failures instead of relying only on structural routing tests.

## Iteration 56 — Real Agent Routing Benchmark Adapter

Iteration 56 adds an actual Ollama-backed routing adapter and closes a benchmark-integrity gap: agent workspaces receive only the task prompt and protocol metadata, never the gold primary/secondary labels. The adapter uses Ollama chat JSON output, normalizes it to the routing result contract, and preserves provider/model provenance for campaign evidence.

## Iteration 57 — Real Agent Routing Campaign and Confusion Analysis

Iteration 57 adds the executable `bin/routing-campaign` command and `bin/routing-analyze` report generator. The runner validates Ollama availability/model presence, executes the configured repeated routing campaign, then produces per-case stability and expected-primary versus observed-primary confusion evidence. A missing model/runtime is reported explicitly rather than producing synthetic benchmark results.

## Iteration 58 — Routing Remediation and Before/After Regression Gate

Iteration 58 adds `router/ROUTING_REMEDIATION.yml` and `bin/routing-compare`. The comparator takes a baseline and candidate campaign and reports metric deltas, resolved/new confusion pairs, and per-case routing changes. The remediation gate rejects incomplete campaigns, primary/secondary regressions, newly introduced primary confusion pairs, and case-level primary regressions according to explicit thresholds.

## Iteration 59 — Reproducible Routing Baseline/Candidate Experiment

Iteration 59 adds `bin/routing-experiment`, which runs baseline and candidate routing-contract snapshots with the same agent command, model metadata, timeout, and repetitions, then applies the Iteration 58 comparison gate. This makes routing remediation experiments reproducible and isolates the routing contract as the intended experimental variable.

## Iteration 66 — External Routing Campaign Handoff

Iteration 66 adds a portable external-runtime handoff for the public routing campaign and defines the private/hidden benchmark boundary. The handoff captures the exact repository SHA, public 14-case/3-repetition protocol, model/runtime settings, and contract hashes, then emits an executable campaign command. Hidden routing cases and gold labels remain external-only and are explicitly forbidden from repository storage or agent exposure.

## Iteration 65 — Routing Campaign Runtime Preflight

Iteration 65 adds a pre-run runtime gate for the real routing campaign. Before any model case executes, the runner records the Ollama runtime version, exact model identity/digest, public case count, repetitions, expected total runs, execution controls, and repository contract hashes. The preflight JSON is preserved as part of campaign evidence when a real run is executed.

## Iteration 64 — Real Routing Campaign Evidence Pack

Iteration 64 adds `bin/routing-campaign-evidence`, which packages a completed public routing campaign together with its analysis, routing contract, repository contracts, and every raw per-run result file. The packager first enforces the Iteration 63 intake gate and records SHA-256 identities plus repository state. It creates a portable evidence boundary without fabricating a result when the external model runtime is unavailable.

## Iteration 63 — Routing Campaign Intake Gate

Iteration 63 adds a strict acceptance boundary for externally produced routing campaigns. The intake verifier requires the configured public corpus, repetition count, complete case coverage, valid registered skills, and complete agent metadata before a real model campaign can be treated as evidence. The current public protocol therefore requires 14 cases × 3 repetitions = 42 completed routing decisions.

## Iteration 62 — Routing Evidence Archive & Benchmark Intake

Iteration 62 adds a portable archive for completed routing evidence. `bin/routing-archive` verifies an evidence package, copies the exact evidence and hashed artifacts into an immutable archive location keyed by campaign/model/repository revision, and refuses silent overwrites. This creates the storage boundary for the first real external-model routing campaign without claiming a benchmark result that has not been observed.

## Iteration 61 — Routing Evidence Integrity & Intake

Iteration 61 hardens routing experiment evidence before the first real external-model campaign. Evidence packaging now records the exact Git revision, branch, worktree cleanliness, and status entries, while rejecting dirty repositories unless explicitly allowed. `bin/routing-evidence-verify` independently validates compatibility, gate state, digest structure, and—when requested—artifact SHA-256s. No local model score is claimed when the external model runtime is unavailable.

## Iteration 60 — Auditable Routing Experiment Evidence

Iteration 60 adds `bin/routing-evidence`, which packages a completed routing experiment with the repository revision, baseline/candidate campaign hashes, exact routing-contract hashes, campaign/schema/remediation-policy hashes, agent configuration, comparison deltas, and replay metadata. This turns external model runs into auditable evidence rather than ephemeral local output.
