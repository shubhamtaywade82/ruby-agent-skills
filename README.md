# Ruby Agent Skills

A repository of **agent-executable Ruby and Ruby on Rails engineering knowledge**.

The goal is not to store passive notes. The repository turns engineering material into a system an AI coding agent can use to **classify a task, inspect a repository, select skills and patterns, implement a bounded change, verify behavior, and report evidence**.

## Quick start

Install the verified skill pack from a release archive (offline; no git required):

    curl -LO https://github.com/shubhamtaywade82/ruby-agent-skills/releases/download/v1.1.0/ruby-agent-skills-v1.1.0.tar.gz
    tar xzf ruby-agent-skills-v1.1.0.tar.gz
    cd ruby-agent-skills-v1.1.0
    bash bin/install --agent claude

Or from a git checkout:

    git clone https://github.com/shubhamtaywade82/ruby-agent-skills
    cd ruby-agent-skills
    bash bin/install --agent claude

Then verify the installed pack:

    ruby bin/skill-pack-verify --root ~/.claude/skills
    ruby bin/skill-pack-doctor --root ~/.claude/skills

Every release publishes a `SHA256SUMS` checksum alongside the archive. See [Installation](#installation) for scopes, agent layouts, pinned refs, and verification workflows.

### Install individual skills with the `skills` CLI

Every skill follows the [Agent Skills specification](https://agentskills.io/specification), so any spec-conformant installer works. With [`npx skills`](https://github.com/vercel-labs/skills) you can browse and install only the skills you need:

    npx skills add shubhamtaywade82/ruby-agent-skills --list
    npx skills add shubhamtaywade82/ruby-agent-skills --skill rails-active-record --skill rails-performance -a claude-code

A CLI install copies the skill folders only. Skills name the implementation patterns they draw on; to install the 447-pattern catalog, routing contract, and provenance verification as well, use `bin/install` above. See [docs/PUBLISHING.md](docs/PUBLISHING.md) for how the pack is published and evaluated.

---

## Agent installation verification

After installing the pack, run `ruby bin/skill-pack-doctor --root <agent-skill-root>` to verify the installed metadata, skill inventory, embedded verifier, and content integrity before using the pack in a controlled agent environment.

## Routing evidence integrity

`bin/routing-compare` recomputes routing metrics from the recorded run data before applying the remediation gate. A campaign whose recorded metrics have been altered or drifted from its runs is rejected rather than treated as benchmark evidence.

## Routing campaign analysis

After a public routing campaign completes, the campaign finalization path regenerates the canonical routing analysis automatically. The analyzer remains directly runnable for independent inspection:

    ruby bin/routing-analyze ./routing-campaign-output/campaign.json \
      --output ./routing-campaign-output/analysis.json

The analyzer recomputes completion and routing metrics from the recorded runs and rejects structurally inconsistent or incomplete campaigns rather than filling missing measurements.

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

### Skill layout and progressive disclosure

An agent loads a whole `SKILL.md` when the skill activates, so `SKILL.md` holds only what is needed to act: purpose, activation, repository inspection, decision rules, critical invariants, the domain change contract, review checklist, failure modes, and verification. Deep framework knowledge lives in skill-local `references/*.md` files that the agent loads only when the change touches that boundary. The `## References` table in each `SKILL.md` says when to load each file and which patterns to consult.

```text
skills/rails-active-record/
├── SKILL.md                 # operating playbook, always loaded on activation
└── references/              # loaded on demand, one level deep
    ├── relations-and-queries.md
    ├── persistence-lifecycle-and-callbacks.md
    └── ...
```

`scripts/validate_skills.rb` enforces the budget from the Agent Skills specification: at most 500 lines and about 5,000 estimated tokens per `SKILL.md`, reference files at most 500 lines, directly under `references/`, never linking to another reference, and every reference linked from `SKILL.md`. The repository target of 350 lines / about 3,500 tokens is reported but not enforced. Patterns stay in the shared `patterns/` catalog; a skill names the pattern to consult rather than copying it.

### Current validated inventory

| Capability | Count |
|---|---:|
| Skills | **96** |
| Implementation patterns | **447** |
| Evaluation cases | **492** |
| Dedicated system/contract tests | **102** |
| Manifest version | **2** |

The exact inventory is governed by `skill-manifest.yml`; `bin/validate` is the source of truth for library-contract validation.

# Skill coverage

## Ruby fundamentals

The Ruby foundation covers:

- Ruby toolchain and environment setup
- RubyGems/Bundler installation and executable provenance
- Ruby gem development, packaging, and release boundaries

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

`ruby-core` · `ruby-toolchain` · `ruby-gem-development` · `ruby-data-types` · `ruby-control-flow` · `ruby-collections` · `ruby-blocks-procs-lambdas` · `ruby-enumerables` · `ruby-api-design` · `ruby-method-design` · `ruby-oop` · `ruby-modules-mixins` · `ruby-metaprogramming` · `ruby-poro` · `ruby-service-objects` · `ruby-domain-modeling` · `ruby-dependency-injection` · `ruby-object-composition` · `ruby-boolean-logic` · `ruby-gems-io-services` · `ruby-debugging` · `ruby-clean-code` · `ruby-tdd-refactoring` · `ruby-concurrency` · `ruby-performance` · `ruby-runtime-compatibility`

## React and TypeScript

This pack owns the Rails side of the Rails ↔ React seam through `rails-react-integration`:
- integration mode (Inertia, JSON API, or islands);
- typed and runtime-validated Rails JSON;
- CSRF and session handling from `fetch`;
- Rails 422 errors in forms;
- pagination.

Standalone React and TypeScript engineering belongs to [react-agent-skills](https://github.com/shubhamtaywade82/react-agent-skills). The in-pack frontend skills below are deprecated: they are kept only to maintain existing work and will be removed in a later release.

Retained: `rails-react-integration`

### Full-stack Rails + React

This pack does not copy React skills. For a Rails backend with a React frontend, install both packs:

    bash bin/install --agent claude                                   # this pack (Rails, Ruby, the seam)
    npx skills add shubhamtaywade82/react-agent-skills -a claude-code  # React + TypeScript client

Install `react-agent-skills` after this pack while the deprecated skills below still ship: they share directory names with their react-agent-skills replacements, and the last install wins. `agent-workflow` also exists in both packs; see [docs/INSTALLATION.md](docs/INSTALLATION.md#companion-pack-react-agent-skills).

Agents then route by boundary (see `router/ROUTING.md`, "Rails and React cross-stack routing"):

| Change | Load |
|---|---|
| Rails only (model, controller, job, serializer) | this pack |
| Seam (fetch from React, CSRF/session, 422 mapping, pagination, Action Cable, direct upload, Inertia) | `rails-react-integration` + the owning Rails skill, then the react-agent-skills skills it names |
| React only (component, hook, client state, styling, client test) | react-agent-skills |

When `react-agent-skills` is not installed, `rails-react-integration` still does the seam work and names the client-side follow-up and the react-agent-skills skill that owns it.

Deprecated: `typescript-core-engineering` · `typescript-type-design` · `typescript-runtime-contracts` · `react-component-engineering` · `react-state-effects` · `react-data-fetching` · `react-testing-engineering` · `react-accessibility-performance` · `react-architecture`

## Core Rails

- `rails-application-bootstrap`
- `rails-architecture`
- `rails-routing`
- `rails-action-controller`
- `rails-data-modeling`
- `rails-active-record`
- `rails-associations`
- `rails-validations`
- `rails-authentication`
- `rails-generators`
- `rails-security`

## Deep framework engineering

The repository now has dedicated deep skills for:

- **Action Controller** — request/response boundaries, strong parameters, sessions/cookies, callbacks, negotiation, conditional responses, streaming/downloads, exception mapping.
  Resource loading is explicitly treated as a boundary-placement decision: narrow callbacks for shared request prerequisites, action-local lookup when clearer for one-off actions, and memoized readers only as a lazy-access option—not as an inherent performance optimization.
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

# Rails Authentication Engineering

This coverage deepens authentication from a shallow sign-in/sign-out reference into a lifecycle and security boundary.

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

This coverage deepens Rails frontend infrastructure into an explicit build/runtime boundary covering asset strategy selection, Importmap, JavaScript and CSS bundling, development process orchestration, dependency/runtime contracts, reproducibility, production parity, artifact/cache identity, supply-chain security, and release verification.

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

This coverage deepens the Rails request boundary into explicit Rack/middleware engineering coverage.

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

# React + TypeScript frontend migration

Standalone React + TypeScript engineering is moving to shubhamtaywade82/react-agent-skills.

The following frontend skills are deprecated for new standalone frontend work but remain installed during the deprecation window:
- typescript-core-engineering -> react-agent-skills / typescript-core-engineering
- typescript-type-design -> react-agent-skills / typescript-type-design
- typescript-runtime-contracts -> react-agent-skills / typescript-runtime-contracts
- react-component-engineering -> react-agent-skills / react-component-engineering
- react-state-effects -> react-agent-skills / react-hooks-effects + react-state-management
- react-data-fetching -> react-agent-skills / react-data-fetching
- react-testing-engineering -> react-agent-skills / react-testing-engineering + frontend-e2e
- react-accessibility-performance -> react-agent-skills / react-accessibility + react-performance
- react-architecture -> react-agent-skills / react-architecture

See docs/REACT_AGENT_SKILLS_MIGRATION.md for retention and removal gates. Rails backend and cross-boundary integration skills remain in this repository.
 
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

Process skills sit around the Ruby and Rails skills: `agent-workflow` runs the implementation loop (test-first at agreed seams, focused tests per slice, one full-suite run), `change-review` reviews a diff on two separate axes (repository standards and spec fidelity), `ruby-debugging` builds a failing feedback loop before any hypothesis, `ruby-domain-modeling` keeps a domain glossary and decision records, and `ruby-api-design` applies deep-module design. The planning layer turns ideas into decisions and work before any code: `planning-interview` settles a design with the user in rounds, `planning-spec` writes it up with agreed test seams, `planning-tickets` slices it into vertical tickets with blocking edges, and `planning-wayfinder` charts efforts larger than one session. `planning-tracker` stores their items as local Markdown files (validated by its bundled script) or as GitHub Issues. `docs/WRITING_SKILLS.md` covers how to write skills for agents. Several of these disciplines are adapted from https://github.com/mattpocock/skills (MIT License, Copyright (c) 2026 Matt Pocock).

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

Current validated evaluation inventory: **490 cases**.

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

# Change verification

`bin/validate` checks this pack. To check a change in **your** project, run:

```bash
ruby bin/verify-change /path/to/app --base origin/main --strict --out verify-change.json
```

It runs the project's own RuboCop (changed files), tests, Brakeman, bundler-audit, and `zeitwerk:check`, plus deterministic checks (Gemfile/lockfile sync, migration/schema sync, tests changed alongside source), and writes an evidence report with git provenance, per-check status, commands, exit codes, and output tails. It is provider-neutral, uses only the standard library, and never reports a check it could not run as passed: the overall status is `pass`, `fail`, or `incomplete`, and `--strict` turns `incomplete` into a failing exit code for CI.

It also lists the owning skills whose change contract applies to the changed paths. That is a routing hint, not a verification of adherence. See `docs/VERIFY_CHANGE.md`.

---

# Repository validation

The repository has one integrated validation entry point:

```bash
bin/validate
```

Ruby style is enforced separately in CI with `bundle exec rubocop` (configuration in `.rubocop.yml`; the pre-existing offense baseline lives in `.rubocop_todo.yml` and only shrinks).

Validation covers:

- skill contracts, including the SKILL.md size gate and skill-local reference structure
- pattern contracts
- evaluation contracts
- runtime/security/loader/observability/database/production/test-engineering system checks
- manifest consistency
- routing/activation contracts
- adversarial routing quality contracts
- benchmark fixture consistency

The validation suite currently reports the same inventory shown above: **96 skills**, **447 implementation patterns**, **492 evaluation cases**, and **102 dedicated system/contract tests**.

The exact counts are enforced by `scripts/audit_repository_completeness.rb` and `bin/validate`.

---

# Repository structure

```text
ruby-agent-skills/
├── skills/                    # agent skills: SKILL.md + optional references/
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
│   ├── verify-change
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

---

# Installation

Install the agent-facing skill pack with:

    bash bin/install --agent claude

The installer supports user/project scopes and the `agents`, `codex`, `claude`, and `copilot` layouts. It installs skills directly into the target skill directory and keeps patterns, routing, the manifest, and installation provenance under `.ruby-agent-skills/`.

Verify an installation with:

    ruby bin/skill-pack-verify --root ~/.claude/skills

Releases are cut as `vX.Y.Z` git tags and publish a downloadable, checksummed archive that installs offline (no git required). The latest archive is always available from the [releases page](https://github.com/shubhamtaywade82/ruby-agent-skills/releases). See `RELEASE.md` for the release definition and process.

See `docs/INSTALLATION.md` for pinned-ref, offline-archive, project-scope, and verification workflows.
See `docs/IMPLEMENTATION_HANDOFF.md` for the complete clone, validation, installation, routing-campaign, and empirical handoff sequence.

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
9. update this README when user-facing capability or architecture changes, and record the iteration in `CHANGELOG.md` and `docs/ITERATIONS.md`;
10. run `bin/validate`;
11. verify CI before reporting completion.

---

# Current status

The repository-side implementation is complete: checkpointed routing campaigns, resumable multi-model execution, provenance-bound installation, exact installed-pack verification, Rails ↔ React integration coverage, the installed-pack doctor, routing-campaign analysis, and a release line of reproducible, checksummed archives with offline installation, a tag-triggered release workflow, and published GitHub releases.

Remaining work is empirical execution with a reachable external model runtime: capture real campaign evidence, analyze observed routing behavior, run evidence-based remediation experiments, execute the external hidden benchmark, and publish verified release evidence.

The ordered iteration history is in [`docs/ITERATIONS.md`](docs/ITERATIONS.md); itemized changes are in [`CHANGELOG.md`](CHANGELOG.md).
