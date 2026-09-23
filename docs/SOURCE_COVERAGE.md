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
| Deep Active Record Relation and lifecycle boundary | rails-active-record, rails-activerecord, rails-associations, rails-validations, rails-database-engineering, rails-performance |
| Deep Active Record association lifecycle boundary | rails-associations, rails-active-record, rails-database-engineering, rails-validations, rails-security, rails-performance |
| Deep Action Controller request/response boundary | rails-action-controller, rails-security, rails-observability, rails-caching, rails-test-engineering |
| Models, migrations, Active Record and console | rails-activerecord |
| Authentication | rails-authentication |
| Associations | rails-associations |
| Validations | rails-validations |
| Deep Rails validation lifecycle, contexts, errors, custom validators, uniqueness/database enforcement, bypass paths, and testing | rails-validations, rails-active-record, rails-active-model, rails-database-engineering, rails-associations, rails-api-integration, rails-i18n, rails-security, rails-test-engineering |
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

The repository incorporates the documented review taxonomy from [flyerhzm/rails_best_practices](https://github.com/flyerhzm/rails_best_practices), a Rails code-metric tool. Its documented checks cover model responsibility, associations/query access, database indexes, RESTful routes, controller/view/helper boundaries, migrations, mailers, exception handling, and unused methods.

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

The repository now includes the RSpec Style Guide at https://rspec.rubystyle.guide/ as the style source for RSpec specifications. The guide assumes RSpec 3 or later and points to `rubocop-rspec` as the executable enforcement mechanism.

Coverage is implemented through:
- `skills/rubocop/SKILL.md` — RSpec-aware RuboCop workflow
- `.rubocop.yml` — explicit core RSpec style policies
- `docs/RSPEC_STYLE_GUIDE.md` — source-to-enforcement map
- `rubocop-rspec` — executable RSpec cop implementation

Key source areas include spec layout, example-group structure, subject/let/hooks, contexts, expectations, matchers, doubles, test isolation, naming, and controlled DRYing. The upstream guide explicitly treats itself as a living document, so agents must check installed RSpec/rubocop-rspec versions before assuming a rule is current.
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

The security layer incorporates the Rails Security Guide and operational tooling for Brakeman and bundler-audit.

Coverage includes authentication, authorization, sessions, CSRF, XSS, SQL/query safety, command injection, redirects, file access, SSRF, security headers, secrets, webhooks, tenant isolation, dependency security, scanner interpretation, and abuse-case tests.

Operational artifacts:
- `skills/rails-security/SKILL.md`
- `patterns/rails/security-boundary-review.md`
- `data/security/tools.yml`
- `bin/security-audit`
- `docs/SECURITY.md`
- `evals/security/*`
- `scripts/verify_security_eval.rb`
## Ruby/Rails performance

The performance layer covers evidence-driven benchmarking, profiling, allocations/GC, Active Record query cost, request/job decomposition, caching semantics, concurrency capacity, and YJIT/runtime considerations.

Operational artifacts:
- `skills/ruby-performance/SKILL.md`
- `patterns/ruby-design/performance-investigation.md`
- `patterns/rails/cache-boundary.md`
- `data/performance/tools.yml`
- `evals/performance/*`
- `scripts/verify_performance_eval.rb`
- `benchmarks/performance/campaign.yml`

Primary references:
- https://guides.rubyonrails.org/caching_with_rails.html
- https://guides.rubyonrails.org/performance_testing.html
- https://ruby-doc.org/
- https://github.com/tmm1/stackprof
- https://github.com/ruby-prof/ruby-prof

## Rails Zeitwerk

The repository now has a dedicated loader/constant-structure layer covering Zeitwerk path-to-constant contracts, roots/namespaces, `lib` handling, reloadable vs once-loaded code, initializer timing, inflections, eager loading, engines/custom namespaces, circular dependencies, shadowing, and loader diagnostics.

Operational artifacts:
- `skills/rails-zeitwerk/SKILL.md`
- `patterns/rails/zeitwerk-structure-review.md`
- `data/zeitwerk/tools.yml`
- `bin/zeitwerk-check`
- `test/zeitwerk_check_test.rb`
- `evals/zeitwerk/*`
- `scripts/verify_zeitwerk_eval.rb`

Primary sources:
- https://guides.rubyonrails.org/autoloading_and_reloading_constants.html
- https://github.com/fxn/zeitwerk


## Active Job and background processing

The Active Job layer covers job lifecycle, serialization, GlobalID, idempotency, retry/discard policy, transaction-aware enqueueing, queues/priorities, scheduling/recurring tasks, bulk enqueue, callbacks, concurrency controls, error reporting, graceful shutdown, observability, security of durable payloads, and job testing.

Artifacts:
- `skills/rails-active-job/SKILL.md`
- `patterns/rails/idempotent-job.md`
- `patterns/rails/job-retry-policy.md`
- `patterns/rails/transactional-job-enqueue.md`
- `patterns/rails/concurrency-controlled-job.md`
- `data/active_job/tools.yml`
- `evals/active-job/*`
- `benchmarks/active-job/*`
- `scripts/verify_active_job_eval.rb`

Primary sources:
- https://guides.rubyonrails.org/active_job_basics.html
- https://guides.rubyonrails.org/testing.html
- https://github.com/rails/solid_queue


## Rails request lifecycle and observability

This layer covers Rails request flow, stable HTTP error semantics, Rails.error reporting, request IDs/correlation, TaggedLogging/log tags, sensitive parameter filtering, ActiveSupport::Notifications, application instrumentation, low-cardinality metrics, health/liveness/readiness semantics, middleware ordering, and production debugging.

Artifacts:
- `skills/rails-observability/SKILL.md`
- `patterns/rails/request-error-boundary.md`
- `patterns/rails/request-observability.md`
- `patterns/rails/health-endpoint.md`
- `patterns/rails/instrumentation-event.md`
- `data/observability/tools.yml`
- `evals/observability/*`
- `benchmarks/observability/*`
- `scripts/verify_observability_eval.rb`

Primary references:
- https://guides.rubyonrails.org/action_controller_overview.html
- https://guides.rubyonrails.org/error_reporting.html
- https://guides.rubyonrails.org/active_support_instrumentation.html
- https://guides.rubyonrails.org/configuring.html
- https://guides.rubyonrails.org/debugging_rails_applications.html


## Rails Action Controller

Action Controller is covered as a dedicated HTTP boundary layer because request input, response semantics, session/cookie state, callbacks, format negotiation, HTTP cache validators, streaming/downloads, and controller exception mapping require deeper contracts than the basic rails-controllers skill.

Operational coverage:
- skills/rails-action-controller/SKILL.md
- patterns/rails/action-controller-request-boundary.md
- patterns/rails/strong-parameters-contract.md
- patterns/rails/controller-response-contract.md
- patterns/rails/controller-session-cookie-boundary.md
- patterns/rails/action-controller-callback-contract.md
- patterns/rails/controller-content-negotiation.md
- patterns/rails/conditional-response-cache.md
- patterns/rails/controller-streaming-download.md
- patterns/rails/controller-exception-boundary.md
- patterns/rails/action-controller-testing.md
- evals/rails/action-controller-contract.yml
- test/rails_action_controller_system_test.rb

Primary sources:
- https://guides.rubyonrails.org/action_controller_overview.html
- https://api.rubyonrails.org/classes/ActionController/Parameters.html
- https://api.rubyonrails.org/classes/ActionController/Redirecting.html
- https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html
- https://api.rubyonrails.org/classes/ActionController/Rescue.html

## Rails Associations

Active Record associations are covered as a dedicated relationship/lifecycle boundary because cardinality, inverse identity, join mutation, polymorphism, dependent deletion, autosave, counter/touch coupling, and collection callbacks have distinct behavior from general Relation/query semantics.

Operational coverage:
- skills/rails-associations/SKILL.md
- patterns/rails/association-cardinality-contract.md
- patterns/rails/association-inverse-contract.md
- patterns/rails/through-association-contract.md
- patterns/rails/polymorphic-association-boundary.md
- patterns/rails/association-dependent-lifecycle.md
- patterns/rails/association-autosave-contract.md
- patterns/rails/association-counter-touch-contract.md
- patterns/rails/association-callback-contract.md
- patterns/rails/association-loading-contract.md
- patterns/rails/association-testing.md
- evals/rails/associations-contract.yml
- test/rails_associations_system_test.rb

Primary source:
- https://guides.rubyonrails.org/association_basics.html

## Rails Active Record

Active Record is covered by a dedicated deep engineering layer because model and Relation semantics extend beyond basic CRUD. The skill deliberately separates object/query contracts from database infrastructure.

Operational coverage:
- skills/rails-active-record/SKILL.md
- patterns/rails/active-record-model-boundary.md
- patterns/rails/active-record-query-contract.md
- patterns/rails/active-record-relation-composition.md
- patterns/rails/active-record-scope-contract.md
- patterns/rails/active-record-persistence-lifecycle.md
- patterns/rails/active-record-callback-contract.md
- patterns/rails/active-record-bulk-write-boundary.md
- patterns/rails/active-record-strict-loading.md
- patterns/rails/active-record-deletion-contract.md
- patterns/rails/active-record-testing.md
- evals/rails/active-record-contract.yml
- test/rails_active_record_system_test.rb

Primary sources:
- https://guides.rubyonrails.org/active_record_basics.html
- https://guides.rubyonrails.org/active_record_querying.html
- https://guides.rubyonrails.org/active_record_callbacks.html
- https://guides.rubyonrails.org/association_basics.html
- https://guides.rubyonrails.org/active_record_validations.html

## Rails database engineering

This layer covers production schema changes, migration reversibility, DDL transactions, indexes, PostgreSQL concurrent index creation, database constraints, foreign keys, nullability/type changes, expand-contract deployments, data backfills, transaction boundaries, isolation, pessimistic locking, deadlocks, query plans, bulk Active Record writes, connection pools, and multi-database/role considerations.

Artifacts:
- `skills/rails-database-engineering/SKILL.md`
- `patterns/rails/expand-contract-migration.md`
- `patterns/rails/production-index.md`
- `patterns/rails/database-constraint.md`
- `patterns/rails/batched-backfill.md`
- `patterns/rails/transaction-lock-boundary.md`
- `data/database-engineering/tools.yml`
- `evals/database/*`
- `benchmarks/database-engineering/*`
- `scripts/verify_database_engineering_eval.rb`

Primary references:
- https://guides.rubyonrails.org/active_record_migrations.html
- https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html
- https://api.rubyonrails.org/classes/ActiveRecord/Locking/Pessimistic.html
- https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/ConnectionPool.html
- https://api.rubyonrails.org/classes/ActiveRecord/Relation.html
- https://www.postgresql.org/docs/current/sql-createindex.html


## Rails production runtime

This layer covers Puma worker/thread capacity, aggregate database/process resource budgets, boot/preload behavior, hot versus phased restart semantics, graceful shutdown, Solid Queue process topology, Puma/Solid Queue coupling, container PID 1 and signal forwarding, readiness gates, release/migration ordering, queued-job compatibility, runtime configuration and Rails master-key requirements, resource limits, process managers, and rollback boundaries.

Artifacts:
- `skills/rails-production-runtime/SKILL.md`
- `patterns/rails/puma-capacity.md`
- `patterns/rails/graceful-shutdown.md`
- `patterns/rails/zero-downtime-release.md`
- `patterns/rails/runtime-config-contract.md`
- `patterns/rails/release-migration-gate.md`
- `data/production-runtime/tools.yml`
- `evals/runtime/*`
- `benchmarks/production-runtime/*`
- `scripts/verify_production_runtime_eval.rb`

Primary references:
- https://guides.rubyonrails.org/getting_started.html
- https://guides.rubyonrails.org/configuring.html
- https://guides.rubyonrails.org/security.html
- https://puma.io/puma/file.deployment.html
- https://puma.io/puma/file.restart.html
- https://github.com/rails/solid_queue


## Rails test engineering

This layer covers test-boundary selection, request/integration/system testing, Active Job testing, mailer and Action Cable testing, fixtures/factories, deterministic time and asynchronous tests, database isolation, parallel tests, flaky-test diagnosis, test-suite performance, CI test strategy, eager-load testing, and test-doubles at real external boundaries.

Artifacts:
- `skills/rails-test-engineering/SKILL.md`
- `patterns/testing/test-boundary-selection.md`
- `patterns/testing/deterministic-async-test.md`
- `patterns/testing/parallel-safe-test.md`
- `patterns/testing/flaky-test-diagnosis.md`
- `patterns/testing/test-performance-budget.md`
- `patterns/testing/system-test-contract.md`
- `patterns/testing/request-contract.md`
- `patterns/testing/parallel-database-test.md`
- `data/test-engineering/tools.yml`
- `evals/test-engineering/*`
- `benchmarks/test-engineering/*`
- `scripts/verify_test_engineering_eval.rb`

Primary reference:
- https://guides.rubyonrails.org/testing.html

Supporting reference:
- https://guides.rubyonrails.org/active_job_basics.html

## Rails caching engineering

Caching is covered as a dedicated correctness/system boundary rather than only as a performance optimization.

Operational coverage:
- skills/rails-caching/SKILL.md
- patterns/rails/cache-boundary.md
- patterns/rails/cache-key-isolation.md
- patterns/rails/cache-invalidation-contract.md
- patterns/rails/cache-stampede-control.md
- patterns/rails/cache-failure-boundary.md
- patterns/rails/cache-warming-strategy.md
- patterns/rails/cache-capacity-review.md
- evals/performance/cache-key-boundary.yml

The repository synthesis emphasizes identity isolation, freshness, invalidation ownership, release compatibility, bounded recomputation, failure behavior, and cache capacity.
## Rails Action Mailer

The repository adds a dedicated Action Mailer engineering layer because outbound email combines Rails templating, Active Job delivery, external-provider failure semantics, security/privacy boundaries, and operational observability.

Operational coverage:
- `skills/rails-action-mailer/SKILL.md`
- `patterns/rails/mailer-contract.md`
- `patterns/rails/mailer-delivery-semantics.md`
- `patterns/rails/mailer-provider-boundary.md`
- `patterns/rails/mailer-security-boundary.md`
- `patterns/rails/mailer-testing.md`
- `patterns/rails/mailer-observability.md`
- `evals/rails/action-mailer-contract.yml`

Primary source: https://guides.rubyonrails.org/action_mailer_basics.html
## Rails Active Storage

Active Storage is covered by a dedicated framework skill because file attachments cross database, object-storage, browser-upload, authorization, processing, cleanup, and operational boundaries.

Operational coverage:
- `skills/rails-active-storage/SKILL.md`
- `patterns/rails/active-storage-boundary.md`
- `patterns/rails/active-storage-upload-security.md`
- `patterns/rails/active-storage-direct-upload.md`
- `patterns/rails/active-storage-serving.md`
- `patterns/rails/active-storage-processing.md`
- `patterns/rails/active-storage-purge.md`
- `patterns/rails/active-storage-testing.md`
- `evals/rails/active-storage-contract.yml`

Primary source: https://guides.rubyonrails.org/active_storage_overview.html
## Rails Action Cable & realtime

Action Cable is covered by a dedicated skill because long-lived WebSockets combine connection authentication, resource authorization, pub/sub delivery, reconnect semantics, fan-out capacity, and deployment/runtime behavior that are distinct from ordinary HTTP requests.

Operational coverage:
- `skills/rails-action-cable/SKILL.md`
- `patterns/rails/action-cable-connection-auth.md`
- `patterns/rails/action-cable-channel-authorization.md`
- `patterns/rails/action-cable-stream-contract.md`
- `patterns/rails/action-cable-broadcast-contract.md`
- `patterns/rails/action-cable-reconciliation.md`
- `patterns/rails/action-cable-capacity.md`
- `patterns/rails/action-cable-failure-boundary.md`
- `patterns/rails/action-cable-testing.md`
- `evals/rails/action-cable-contract.yml`

Primary source: https://guides.rubyonrails.org/action_cable_overview.html
## Rails I18n & localization

I18n is covered by a dedicated skill because locale selection, request isolation, translation contracts, formatting, routes, jobs, mailers, APIs, caches, and translation backends form a cross-layer Rails boundary.

Operational coverage:
- `skills/rails-i18n/SKILL.md`
- `patterns/rails/i18n-locale-resolution.md`
- `patterns/rails/i18n-translation-key-contract.md`
- `patterns/rails/i18n-pluralization-formatting.md`
- `patterns/rails/i18n-localized-routing.md`
- `patterns/rails/i18n-context-propagation.md`
- `patterns/rails/i18n-cache-identity.md`
- `patterns/rails/i18n-security-boundary.md`
- `patterns/rails/i18n-testing.md`
- `evals/rails/i18n-contract.yml`

Primary source: https://guides.rubyonrails.org/i18n.html
## Rails Action Text

Action Text is covered by a dedicated skill because rich text combines persisted RichText records, Trix editing, server-side sanitization, embedded Active Storage resources, Signed Global ID attachables, rendering, APIs, localization, and collection performance.

Operational coverage:
- `skills/rails-action-text/SKILL.md`
- `patterns/rails/action-text-content-contract.md`
- `patterns/rails/action-text-sanitization-security.md`
- `patterns/rails/action-text-attachment-authorization.md`
- `patterns/rails/action-text-rendering.md`
- `patterns/rails/action-text-api-boundary.md`
- `patterns/rails/action-text-preload-performance.md`
- `patterns/rails/action-text-lifecycle.md`
- `patterns/rails/action-text-attachable-contract.md`
- `patterns/rails/action-text-testing.md`
- `evals/rails/action-text-contract.yml`

Primary source: https://guides.rubyonrails.org/action_text_overview.html

## Rails Action Mailbox

Current Rails documentation provides a dedicated inbound-email framework separate from Action Mailer. The operational coverage is implemented through:

- skills/rails-action-mailbox/SKILL.md
- patterns/rails/action-mailbox-ingress-boundary.md
- patterns/rails/action-mailbox-routing-contract.md
- patterns/rails/action-mailbox-authenticity-security.md
- patterns/rails/action-mailbox-idempotency.md
- patterns/rails/action-mailbox-processing-lifecycle.md
- patterns/rails/action-mailbox-tenant-association.md
- patterns/rails/action-mailbox-failure-quarantine.md
- patterns/rails/action-mailbox-testing.md
- evals/rails/action-mailbox-contract.yml
- test/rails_action_mailbox_system_test.rb

Source foundation:

- https://guides.rubyonrails.org/action_mailbox_basics.html
- https://api.rubyonrails.org/classes/ActionMailbox/Base.html
- https://api.rubyonrails.org/classes/ActionMailbox/Router.html
- https://api.rubyonrails.org/classes/ActionMailbox/InboundEmail.html
- https://api.rubyonrails.org/classes/ActionMailbox/TestHelper.html

Coverage focuses on ingress authentication, raw-message capture, mailbox routing, sender/resource/tenant authorization, duplicate/replay safety, processing lifecycle, failure/quarantine behavior, attachment boundaries, retention/incineration, observability, capacity, and deterministic tests. The repository intentionally keeps provider-specific contracts at the ingress boundary rather than reproducing provider implementation details inside mailbox classes.


## Rails Action View

Current Rails Action View documentation provides a dedicated rendering layer around templates, partials, layouts, helpers, strict locals, localized views, output safety, and fragment/collection rendering performance. Coverage is implemented through:

- skills/rails-action-view/SKILL.md
- patterns/rails/action-view-partial-contract.md
- patterns/rails/action-view-strict-locals.md
- patterns/rails/action-view-output-safety.md
- patterns/rails/action-view-layout-contract.md
- patterns/rails/action-view-helper-boundary.md
- patterns/rails/action-view-render-performance.md
- patterns/rails/action-view-localized-template.md
- patterns/rails/action-view-testing.md
- evals/rails/action-view-contract.yml
- test/rails_action_view_system_test.rb

Primary sources:
- https://guides.rubyonrails.org/action_view_overview.html
- https://guides.rubyonrails.org/action_view_helpers.html
- https://guides.rubyonrails.org/form_helpers.html
- https://guides.rubyonrails.org/caching_with_rails.html
- https://api.rubyonrails.org/v8.1.3/classes/ActionView/Helpers/SanitizeHelper.html
- https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html


## Rails Active Model

Rails Active Model is the model-like layer for plain Ruby objects that need Rails-facing contracts without Active Record persistence. Coverage is implemented through:

- skills/rails-active-model/SKILL.md
- patterns/rails/active-model-boundary.md
- patterns/rails/active-model-attributes-contract.md
- patterns/rails/active-model-validation-contract.md
- patterns/rails/active-model-dirty-lifecycle.md
- patterns/rails/active-model-callback-boundary.md
- patterns/rails/active-model-conversion-contract.md
- patterns/rails/active-model-serialization-contract.md
- patterns/rails/active-model-testing.md
- evals/rails/active-model-contract.yml
- test/rails_active_model_system_test.rb

Primary source: https://guides.rubyonrails.org/active_model_basics.html

Coverage focuses on the Active Model/PORO boundary, typed attributes, validation/error semantics, Rails conversion/naming, dirty lifecycle, callbacks, serialization/privacy, translation, form integration, and Active Model lint/testing. Persistence remains owned by Active Record and database-engineering skills.


## Rails Active Support

Current Rails Active Support coverage is implemented as a cross-cutting framework layer for utility extensions and infrastructure primitives rather than a replacement for focused Rails skills. It covers:

- skills/rails-active-support/SKILL.md
- patterns/rails/active-support-loading-boundary.md
- patterns/rails/active-support-concern-composition.md
- patterns/rails/active-support-class-configuration.md
- patterns/rails/active-support-current-context.md
- patterns/rails/active-support-notifications-contract.md
- patterns/rails/active-support-callback-boundary.md
- patterns/rails/active-support-time-semantics.md
- patterns/rails/active-support-inflection-boundary.md
- patterns/rails/active-support-testing.md
- evals/rails/active-support-contract.yml
- test/rails_active_support_system_test.rb

Primary sources:
- https://guides.rubyonrails.org/active_support_core_extensions.html
- https://guides.rubyonrails.org/active_support_instrumentation.html
- https://api.rubyonrails.org/classes/ActiveSupport/Concern.html
- https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html
- https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html
- https://api.rubyonrails.org/classes/Class.html

The boundary is intentionally compositional: rails-observability owns production telemetry/diagnostics, rails-zeitwerk owns autoloading, rails-active-model/rails-activerecord own model lifecycles, and rails-security/rails-security-engineering own trust decisions around dynamic names and context.


## Rails Validations engineering

Artifacts:
- skills/rails-validations/SKILL.md
- patterns/rails/validation-boundary.md
- patterns/rails/validation-context-contract.md
- patterns/rails/validation-condition-contract.md
- patterns/rails/validation-uniqueness-database-contract.md
- patterns/rails/validation-associated-graph.md
- patterns/rails/validation-custom-validator.md
- patterns/rails/validation-strict-failure.md
- patterns/rails/validation-error-contract.md
- patterns/rails/validation-callback-boundary.md
- patterns/rails/validation-bypass-audit.md
- patterns/rails/validation-testing.md
- evals/rails/validations-contract.yml
- test/rails_validations_system_test.rb

Primary Rails references:
- https://guides.rubyonrails.org/active_record_validations.html
- https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html
- https://api.rubyonrails.org/classes/ActiveModel/Errors.html

## Deep Rails routing

The routing coverage now extends beyond basic resource declarations to the full public routing contract:

- route precedence and shadowing
- nested and shallow resources
- namespace/path/module/helper scopes
- segment, request, host, subdomain, and format constraints
- path/url and polymorphic helper contracts
- routing concerns
- direct routes and resolve
- Rack/engine mount boundaries
- catch-all and redirect fallback behavior
- localized and host-aware route composition
- route inspection and deterministic route assertions

Primary source: https://guides.rubyonrails.org/routing.html


## Rails Authentication

Rails authentication is implemented as a full lifecycle/security boundary through:

- skills/rails-authentication/SKILL.md
- patterns/rails/authentication-mechanism-boundary.md
- patterns/rails/credential-storage-contract.md
- patterns/rails/session-lifecycle-contract.md
- patterns/rails/session-fixation-rotation.md
- patterns/rails/session-revocation-contract.md
- patterns/rails/password-recovery-contract.md
- patterns/rails/login-abuse-controls.md
- patterns/rails/remember-me-contract.md
- patterns/rails/browser-api-auth-boundary.md
- patterns/rails/authentication-context-propagation.md
- patterns/rails/authentication-freshness-boundary.md
- patterns/testing/authentication-testing.md
- evals/rails/authentication-contract.yml
- test/rails_authentication_system_test.rb

Primary sources:
- https://guides.rubyonrails.org/security.html
- https://guides.rubyonrails.org/8_0_release_notes.html
- https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html
- https://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html

Coverage focuses on authentication mechanism boundaries, credential storage, session lifecycle, fixation resistance, revocation, password recovery, abuse controls, persistent login, browser/API separation, context propagation, freshness, and deterministic security regression testing.

## React and TypeScript engineering

Iteration 77 adds a dedicated frontend engineering family covering TypeScript language/type boundaries, runtime validation, React component architecture, state/effects, server-state data fetching, deterministic UI testing, accessibility/focus, rendering performance, and feature-module architecture.

The new material is operationalized as skills, reusable patterns, and public evaluation cases. It does not attempt to vendor external framework documentation or prescribe one package/library implementation.

Sources:
- https://www.typescriptlang.org/docs/handbook/intro.html
- https://react.dev/learn
- https://react.dev/reference/react
- https://testing-library.com/docs/
- https://www.w3.org/WAI/ARIA/apg/
