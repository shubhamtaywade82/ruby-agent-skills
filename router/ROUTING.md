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
| Runtime/version compatibility | ruby-runtime-compatibility | ruby-core, ruby-gems-io-services, ruby-debugging |
| Ruby syntax/semantics | ruby-core | ruby-clean-code |
| Ruby values/data representation | ruby-data-types | ruby-core, ruby-clean-code |
| Branches/loops/boolean logic | ruby-control-flow | ruby-core, ruby-clean-code |
| Arrays/hashes/Enumerable | ruby-collections | ruby-enumerables, ruby-data-types, ruby-clean-code |\n| Blocks/Procs/lambdas | ruby-blocks-procs-lambdas | ruby-method-design, ruby-tdd-refactoring |\n| Public Ruby API contract | ruby-api-design | ruby-method-design, ruby-oop, ruby-tdd-refactoring |
| Plain Ruby object extraction | ruby-poro | ruby-oop, ruby-object-composition, ruby-tdd-refactoring |
| Application workflow | ruby-service-objects | ruby-poro, ruby-api-design, ruby-tdd-refactoring, pattern:service-object |
| Business concept/invariant modeling | ruby-domain-modeling | ruby-poro, ruby-oop, ruby-clean-code, ruby-tdd-refactoring |
| Replaceable/external collaborator | ruby-dependency-injection | ruby-poro, ruby-api-design, pattern:dependency-injection, ruby-tdd-refactoring |
| Inheritance/coupling refactor | ruby-object-composition | ruby-oop, ruby-dependency-injection, pattern:composition-over-inheritance, ruby-tdd-refactoring |\n| Complex boolean predicates | ruby-boolean-logic | ruby-control-flow, ruby-method-design, ruby-clean-code |
| New/refactored method | ruby-method-design | ruby-clean-code, ruby-tdd-refactoring |
| Class/domain design | ruby-oop | ruby-method-design, ruby-clean-code |
| Shared behavior/namespaces | ruby-modules-mixins | ruby-oop, ruby-clean-code |
| Reflection/metaprogramming | ruby-metaprogramming | ruby-clean-code, ruby-tdd-refactoring |
| File/CSV/HTTP/dependency boundary | ruby-gems-io-services | ruby-api-design, ruby-debugging, ruby-tdd-refactoring, pattern:external-api-client |
| Runtime failure/exception | ruby-debugging | ruby-tdd-refactoring |
| Rails application structure | rails-architecture | ruby-clean-code |
| Rails routes | rails-routing | rails-controllers, rails-testing |
| Rails controller action | rails-controllers | rails-routing, ruby-method-design, rails-testing |
| Rails Action Controller HTTP boundary | rails-action-controller | rails-routing, rails-controllers, rails-authentication, rails-security, rails-api-integration, rails-observability, rails-caching, rails-active-storage, rails-test-engineering, rails-testing |
| Rails view/form | rails-views | rails-controllers, rails-testing |
| Model/migration/query | rails-activerecord | rails-architecture, rails-testing |
| Rails Active Record deep engineering | rails-active-record | rails-activerecord, rails-associations, rails-validations, rails-database-engineering, rails-performance, rails-security, rails-test-engineering, rails-testing |
| Active Record association | rails-associations | rails-activerecord, rails-testing |
| Rails Association deep engineering | rails-associations | rails-active-record, rails-activerecord, rails-database-engineering, rails-validations, rails-security, rails-active-job, rails-active-storage, rails-performance, rails-test-engineering, rails-testing |
| Validation/invariant | rails-validations | rails-activerecord, rails-testing |
| Rails Validation deep engineering | rails-validations | rails-active-record, rails-active-model, rails-associations, rails-database-engineering, rails-action-controller, rails-action-view, rails-api-integration, rails-i18n, rails-security, rails-performance, rails-test-engineering, rails-testing |
| Authentication/session | rails-authentication | rails-controllers, rails-testing |
| Rails test design | rails-testing | relevant implementation skill, ruby-tdd-refactoring |
| Rails generator/scaffold | rails-generators | relevant Rails skill, rails-testing, pattern:scaffold-lifecycle |\n| Rails REST resource | rails-routing | rails-controllers, rails-authentication, rails-testing, pattern:rest-resource |
| Rails deployment/hosting | rails-deployment | rails-architecture, ruby-debugging |
| Rails performance/scalability | rails-performance | ruby-performance, rails-activerecord, rails-database-engineering, rails-active-job, rails-observability, ruby-concurrency, rails-testing |
| Rails caching engineering | rails-caching | rails-performance, ruby-performance, rails-activerecord, rails-database-engineering, rails-active-job, rails-observability, rails-security, rails-security-engineering, rails-testing |
| Rails email / Action Mailer | rails-action-mailer | rails-active-job, rails-api-integration, rails-security, rails-security-engineering, rails-observability, rails-test-engineering, rails-testing, rails-distributed-systems |
| Rails Active Storage / file attachments | rails-active-storage | rails-security, rails-security-engineering, rails-active-job, rails-api-integration, rails-performance, rails-caching, rails-observability, rails-production-runtime, rails-test-engineering, rails-testing |
| Rails Action Cable / realtime WebSockets | rails-action-cable | rails-security, rails-security-engineering, rails-active-job, rails-event-driven-messaging, rails-distributed-systems, rails-reliability-engineering, rails-performance, ruby-performance, ruby-concurrency, rails-production-runtime, rails-release-engineering, rails-observability, rails-test-engineering, rails-testing |
| Rails I18n / localization | rails-i18n | rails-routing, rails-views, rails-validations, rails-api-integration, rails-action-mailer, rails-active-job, rails-caching, rails-security, rails-test-engineering, rails-testing, ruby-concurrency |
| Rails Action Text / rich text | rails-action-text | rails-views, rails-activerecord, rails-validations, rails-active-storage, rails-security, rails-security-engineering, rails-i18n, rails-caching, rails-performance, ruby-performance, rails-api-integration, rails-active-job, rails-test-engineering, rails-testing |
| Rails API and integration architecture | rails-api-integration | rails-routing, rails-controllers, rails-authentication, rails-security, rails-observability, rails-active-job, ruby-api-design, ruby-gems-io-services, ruby-dependency-injection, rails-testing |
| Distributed systems and service architecture | rails-distributed-systems | rails-api-integration, rails-active-job, rails-database-engineering, ruby-concurrency, rails-observability, rails-production-runtime, rails-security, rails-testing |
| Event-driven messaging architecture | rails-event-driven-messaging | rails-distributed-systems, rails-active-job, rails-api-integration, rails-observability, rails-production-runtime, ruby-concurrency, rails-security, rails-testing |
| Reliability engineering and resilience | rails-reliability-engineering | rails-observability, rails-performance, rails-api-integration, rails-distributed-systems, rails-event-driven-messaging, rails-production-runtime, rails-active-job, ruby-concurrency, rails-database-engineering, rails-security, rails-testing |
| Incident response and operational debugging | rails-incident-engineering | rails-observability, rails-reliability-engineering, rails-production-runtime, rails-active-job, rails-event-driven-messaging, rails-distributed-systems, rails-security, rails-security-engineering, rails-performance, rails-testing |
| Release engineering and release readiness | rails-release-engineering | rails-deployment, rails-production-runtime, rails-database-engineering, rails-reliability-engineering, rails-incident-engineering, rails-security-engineering, rails-api-integration, rails-active-job, rails-event-driven-messaging, rails-testing |
| Security engineering and threat modeling | rails-security-engineering | rails-security, rails-authentication, rails-api-integration, rails-distributed-systems, rails-event-driven-messaging, rails-reliability-engineering, rails-database-engineering, rails-testing |
| Rails code-quality review | rails-best-practices | relevant Rails skill, ruby-clean-code, rails-testing, pattern:rails-best-practice-review |
| Code review/refactor | ruby-clean-code | ruby-method-design, ruby-tdd-refactoring |
| RuboCop/linting review | rubocop | ruby-clean-code, relevant implementation skill, pattern:rubocop-review |
| Test-driven change | ruby-tdd-refactoring | relevant implementation skill |
| Primitive with domain behavior | ruby-data-types | ruby-oop, pattern:value-object |
| Multi-step application workflow | ruby-service-objects | ruby-poro, ruby-domain-modeling, pattern:service-object, pattern:application-service, ruby-tdd-refactoring |
| Explicit application command | ruby-service-objects | ruby-api-design, pattern:command, ruby-tdd-refactoring |
| Reusable business decision | ruby-domain-modeling | pattern:policy-object, pattern:specification, ruby-tdd-refactoring |
| Interchangeable implementation | ruby-object-composition | ruby-dependency-injection, pattern:strategy-object, pattern:factory, ruby-tdd-refactoring |
| External boundary | ruby-dependency-injection | pattern:adapter, pattern:dependency-injection, pattern:external-api-client |
| Complex object construction | ruby-object-composition | pattern:factory, pattern:builder, ruby-tdd-refactoring |
| Optional collaborator with safe no-op | ruby-object-composition | pattern:null-object, ruby-tdd-refactoring |
| Layer behavior around stable interface | ruby-object-composition | pattern:decorator, ruby-tdd-refactoring |
| Complex subsystem interface | ruby-object-composition | pattern:facade, ruby-tdd-refactoring |
| Complex persistence abstraction | ruby-domain-modeling | pattern:repository, rails-activerecord, rails-testing |
| Repeated state-specific behavior | ruby-domain-modeling | pattern:state-object, ruby-tdd-refactoring |
| Rails presentation transformation | rails-views | pattern:presenter, rails-testing |
| Interchangeable algorithm/policy | ruby-oop | pattern:strategy-object |
| Replace inheritance with collaborators | ruby-oop | pattern:composition-over-inheritance |
| External/legacy API boundary | ruby-gems-io-services | ruby-api-design, pattern:external-api-client, pattern:adapter, ruby-debugging |\n| Reusable Ruby gem/library | ruby-gems-io-services | ruby-api-design, pattern:ruby-gem |
| Complex/read-oriented Rails query | rails-activerecord | pattern:query-object, rails-testing |
| Multi-model/input validation boundary | rails-controllers | pattern:form-object, rails-validations |
| Authorization boundary | rails-authentication | pattern:policy-boundary, rails-testing |
| Atomic multi-write workflow | rails-activerecord | pattern:transaction-boundary, rails-testing |
| End-to-end Rails endpoint | rails-architecture | pattern:request-flow, rails-testing |
| Bug regression coverage | ruby-debugging | pattern:regression-test, ruby-tdd-refactoring |
| Pair-search on sorted data | ruby-collections | pattern:two-pointers, ruby-tdd-refactoring |
| Repeated membership/counting | ruby-collections | pattern:frequency-map, ruby-tdd-refactoring |

## Runtime compatibility

```text
ruby-runtime-compatibility
  + relevant Ruby/Rails skill
  + ruby-tdd-refactoring (when upgrading behavior)
  + rubocop (when lint/tooling compatibility changes)
```

Resolve runtime evidence before using version-sensitive APIs. Do not choose between conflicting authoritative sources without clarification.

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

### RuboCop review

```text
rubocop
  + relevant implementation skill
  + ruby-clean-code
  + pattern:rubocop-review
  + ruby-tdd-refactoring (behavior changes)
```

Select plugins from `data/rubocop/plugins.yml` only when repository dependencies or the task justify them.

### Rails quality review

```text
rails-best-practices
  + relevant Rails implementation skill
  + ruby-clean-code
  + rails-testing
  + pattern:rails-best-practice-review
```

Treat analyzer findings as signals. Translate historical rules to the actual Rails version and repository contract.

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

## Pattern selection

Patterns are selected **after** skills classify the task.

Use this sequence:

```text
classify task
  -> select skill(s)
  -> inspect repository
  -> check whether an existing local pattern already solves the shape
  -> apply the smallest suitable pattern
  -> adapt names/structure to repository conventions
  -> verify behavior
```

Patterns are optional implementation shapes, not architecture mandates. Book-derived patterns are selected only when the repository/task shape justifies them.

### Pattern restraint

A pattern must not be introduced solely because a trigger matches. Before selecting one, ask whether the direct implementation is already clear, whether the abstraction has a stable responsibility, and whether it reduces coupling or improves testability. Negative design cases are intentional: sometimes the correct architecture is no new object.

### Design-pattern selection matrix

| Problem shape | Candidate pattern |
|---|---|
| Meaningful immutable value | value-object |
| One application workflow | service-object / command |
| Shared service entry-point convention | application-service |
| Reusable business decision | policy-object / specification |
| Interchangeable algorithm | strategy-object |
| External interface mismatch | adapter |
| Add behavior around stable interface | decorator |
| Hide complex subsystem | facade |
| Vary object construction | factory |
| Complex staged construction | builder |
| Safe no-op collaborator | null-object |
| Complex persistence boundary | repository / query-object |
| State-specific behavior | state-object |
| Presentation transformation | presenter |
| Replaceable collaborator | dependency-injection |

Pattern choice is a candidate, not an automatic verdict. Prefer the smallest abstraction supported by repository evidence.

### Pattern composition examples

#### Service workflow

```text
ruby-oop
  + ruby-method-design
  + ruby-gems-io-services (when external boundaries exist)
  + pattern:service-object
  + ruby-tdd-refactoring
```

#### Rails endpoint

```text
rails-routing
  + rails-controllers
  + rails-authentication (when protected)
  + rails-activerecord
  + pattern:request-flow
  + rails-testing
```

#### Complex query

```text
rails-activerecord
  + rails-associations
  + pattern:query-object
  + rails-testing
```

#### Bug fix

```text
ruby-debugging
  + relevant implementation skill
  + pattern:regression-test
  + ruby-tdd-refactoring
```

Do not use a pattern simply because it exists. If a direct implementation is clearer and fits the repository, prefer the direct implementation.


## Book Integration v2 routing examples

### External API client

    ruby-gems-io-services
      + ruby-api-design
      + pattern:external-api-client
      + pattern:adapter (when provider/legacy transport needs isolation)
      + ruby-testing/tdd discipline

### Rails REST resource

    rails-routing
      + rails-controllers
      + rails-authentication (when protected)
      + pattern:rest-resource
      + pattern:request-flow
      + rails-testing

### Rails scaffold cleanup

    rails-generators
      + pattern:scaffold-lifecycle
      + relevant resource skills
      + rails-testing

### Ruby gem extraction

    ruby-gems-io-services
      + ruby-api-design
      + pattern:ruby-gem
      + ruby-tdd-refactoring

## Concurrency

```text
shared mutable state / concurrent I/O / Thread / Queue / Mutex / deadlock
  -> ruby-concurrency
  -> ruby-runtime-compatibility when runtime-sensitive
  -> ruby-dependency-injection when collaborators require isolation
  -> ruby-debugging + ruby-tdd-refactoring for concurrency defects
  -> bounded-concurrency only when capacity and lifecycle justify it
```

Do not activate concurrency merely because code is slow. First establish the workload, bottleneck, ownership model, and existing Rails/repository executor infrastructure.
## Security

```text
authentication / authorization / untrusted input / scanner finding / secrets / injection / webhook / tenant isolation
  -> rails-security
  -> ruby-runtime-compatibility when version-sensitive
  -> relevant Rails skill (controllers, Active Record, authentication, testing)
  -> security-boundary-review when a concrete trust boundary needs review
  -> ruby-debugging when diagnosing a security defect
```

Security findings are reviewed as trust-boundary/data-flow evidence. Do not reduce security work to a style/lint pass.
## Performance

```text
slow endpoint / job / query / memory / allocations / benchmark / profiler / cache
  -> ruby-performance
  -> rails-activerecord when DB/query work is involved
  -> ruby-concurrency when concurrency/capacity is involved
  -> rails-security when cache/auth/tenant boundaries are security-sensitive
  -> performance-investigation when a measured bottleneck needs a concrete optimization
  -> cache-boundary when introducing or reviewing cache semantics
```

Do not activate performance guidance merely because code could theoretically be optimized. Require a workload, symptom, or explicit measurable target.

## Rails Performance

```text
slow Rails endpoint / Active Record N+1 / query plan / cache stampede /
connection pool / Puma capacity / job throughput / Rails memory
  -> rails-performance
  -> ruby-performance for profiling, allocations, GC, or benchmark methodology
  -> rails-activerecord for query implementation
  -> rails-database-engineering for index, lock, pool, and database capacity changes
  -> rails-active-job for background-job execution semantics
  -> rails-observability for telemetry and production evidence
  -> ruby-concurrency for thread/worker contention and capacity reasoning
  -> rails-testing for regression and deterministic performance tests
```

Require a workload or measurable symptom. Inspect actual Rails/database/runtime configuration before changing concurrency, caching, query shape, or indexes.

## Rails API and integration architecture

```text
API contract / versioning / serialization / external HTTP / webhook /
idempotency / retry / rate limit / provider adapter / integration test
  -> rails-api-integration
  -> rails-routing for dispatch
  -> rails-controllers for HTTP orchestration
  -> rails-authentication for identity/session
  -> rails-security for trust boundaries/secrets
  -> rails-observability for correlation/diagnostics
  -> rails-active-job for asynchronous processing
  -> ruby-api-design for public Ruby contracts
  -> ruby-gems-io-services for transport/dependency boundaries
  -> ruby-dependency-injection for replaceable clients/transports
  -> rails-testing for contract/integration tests
```

Classify the boundary first. Preserve existing API/auth/versioning conventions and make retry, idempotency, replay, and error semantics explicit.

### Integration pattern selection

| Problem shape | Pattern |
|---|---|
| API consumers must survive a contract change | pattern:api-contract-versioning |
| Provider client needs bounded timeout/retry behavior | pattern:resilient-http-client |
| Provider sends signed callbacks | pattern:webhook-ingestion |
| Mutation may arrive more than once | pattern:idempotent-request |

## Zeitwerk / autoloading

```text
constant/file-path/load/reload/eager-load/namespace/inflection issue
  -> rails-zeitwerk
  -> ruby-runtime-compatibility
  -> rails-architecture when application structure changes
  -> ruby-debugging for loader failures
  -> zeitwerk-structure-review for concrete structural review
```

Do not add arbitrary `require` or `require_dependency` calls before identifying the expected constant, loader root, namespace, and inflection.


## Active Job / background jobs

```text
background job / Active Job / ApplicationJob / perform_later / retry / discard / queue / Solid Queue
  -> rails-active-job
  -> ruby-runtime-compatibility
  -> ruby-tdd-refactoring
  -> rails-activerecord when persistence or transaction boundaries are involved
  -> ruby-concurrency when overlap/capacity/concurrency is involved
  -> rails-security when authorization, secrets, or tenant isolation is involved
  -> idempotent-job when repeated side effects must be safe
  -> job-retry-policy when exception semantics need explicit retry/discard design
  -> transactional-job-enqueue when commit timing affects correctness
  -> concurrency-controlled-job when per-resource overlap must be bounded
```

Do not treat "runs in the background" as sufficient design. Resolve serialization, idempotency, retry, transaction, concurrency, observability, and recovery semantics.


## Rails request lifecycle / observability

```text
API error handling / Rails.error / error reporting / request ID / logging /
ActiveSupport::Notifications / instrumentation / health / liveness / readiness
  -> rails-observability
  -> rails-controllers
  -> ruby-debugging
  -> rails-security when sensitive-data or trust-boundary concerns exist
  -> ruby-performance when logging/instrumentation has measurable overhead
  -> request-error-boundary for stable exception-to-HTTP mappings
  -> request-observability for correlation/logging/metrics
  -> health-endpoint for liveness/readiness semantics
  -> instrumentation-event for stable application events
```

Prefer an existing framework/request boundary over introducing duplicate middleware or controller callbacks.


## Rails database engineering

```text
migration / schema / index / constraint / backfill / transaction /
locking / isolation / deadlock / connection pool / query plan /
zero-downtime database change
  -> rails-database-engineering
  -> rails-activerecord
  -> rails-testing
  -> ruby-concurrency when contention/capacity is involved
  -> ruby-performance when query/index/pool performance is the measured problem
  -> ruby-runtime-compatibility for version-sensitive database APIs
  -> rails-security when database changes affect tenant isolation or sensitive data
  -> expand-contract-migration for rolling-deploy compatibility
  -> production-index for live index changes
  -> database-constraint for cross-writer invariants
  -> batched-backfill for production data transformation
  -> transaction-lock-boundary for concurrent state transitions
```

Do not treat a Rails migration as an isolated file. Inspect data volume, deployment overlap, database/adapter behavior, locks, and recovery semantics.


## Rails production runtime

```text
Puma / production process model / workers / threads / graceful shutdown /
zero-downtime release / Solid Queue topology / container lifecycle /
runtime configuration / release ordering / rollback
  -> rails-production-runtime
  -> rails-deployment
  -> rails-database-engineering when schema/migration is involved
  -> rails-active-job when queued work or Solid Queue is involved
  -> rails-observability for readiness/health/diagnostics
  -> ruby-concurrency for process/thread/fiber capacity
  -> ruby-performance for measured capacity/resource problems
  -> rails-security for secrets/configuration boundaries
```

Do not select worker counts, restart modes, or deployment sequencing from generic defaults. Inspect the actual platform/runtime configuration.


## Rails test engineering

```text
test boundary / request test / integration / system test / job test /
test isolation / flaky test / parallel tests / transactional tests /
test performance / CI test execution / fixtures / factories
  -> rails-test-engineering
  -> rails-testing
  -> ruby-tdd-refactoring
  -> ruby-concurrency when thread/process concurrency is involved
  -> ruby-performance for measured test-runtime problems
  -> rails-active-job when job queue semantics are tested
  -> rails-database-engineering when test behavior depends on DB transactions/locks
  -> rails-security when security boundaries are the contract under test
```

Use the repository's existing test framework and helpers. Do not introduce a second testing stack merely because it offers a different style.


## Distributed systems and service architecture

```text
cross-process/service boundary / queue / broker / event / outbox / inbox /
eventual consistency / saga / distributed lock / replay / reconciliation
  -> rails-distributed-systems
  -> rails-api-integration for synchronous APIs/webhooks and contract compatibility
  -> rails-active-job for asynchronous execution/retry/concurrency
  -> rails-database-engineering for transaction/constraint/locking ownership
  -> ruby-concurrency for in-process coordination and capacity
  -> rails-observability for correlation/causation and state transitions
  -> rails-production-runtime for process topology and rollout/shutdown
  -> rails-security for cross-service trust and credentials
  -> rails-testing for deterministic failure/replay coverage
```

Classify the failure model before selecting a mechanism. Prefer local atomicity over distributed coordination when one owner can enforce the invariant.

### Distributed pattern selection

| Problem shape | Pattern |
|---|---|
| Independent service/data ownership | pattern:distributed-service-boundary |
| Database commit must hand off a message atomically | pattern:outbox-publication |
| At-least-once consumer needs durable deduplication | pattern:inbox-deduplication |
| Delivery/ack/replay semantics need explicit contract | pattern:message-delivery-contract |
| Workflow spans independent transactions | pattern:saga-orchestration |
| Cross-process exclusion is unavoidable | pattern:distributed-lock |
| Consumers observe asynchronous propagation | pattern:eventual-consistency |


## Event-driven messaging architecture

```text
event/command / broker / queue / stream / topic / partition / consumer group /
schema evolution / dead letter / replay / lag / message tracing / capacity
  -> rails-event-driven-messaging
  -> rails-distributed-systems for ownership, consistency, and failure model
  -> rails-api-integration for synchronous boundaries and provider contracts
  -> rails-active-job for Rails-managed asynchronous execution
  -> rails-observability for correlation and message lifecycle
  -> rails-production-runtime for consumer process/shutdown topology
  -> ruby-concurrency for bounded consumer concurrency
  -> rails-security for trust, permissions, and secrets
  -> rails-testing for deterministic message/failure tests
```

Classify the message before designing transport mechanics. Keep broker-specific types at the handler boundary and treat replay as a production capability.

### Messaging pattern selection

| Problem shape | Pattern |
|---|---|
| Shared message metadata/identity contract | pattern:event-envelope |
| Old/new producers and consumers coexist | pattern:event-schema-evolution |
| Ordering and parallel consumer topology | pattern:consumer-group-partitioning |
| Poison-message containment and replay | pattern:dead-letter-replay |
| End-to-end message lifecycle diagnostics | pattern:message-observability |
| Lag/backpressure/downstream capacity | pattern:broker-capacity |
| Isolate broker mechanics from domain logic | pattern:message-handler-boundary |


## Reliability engineering and resilience

```text
SLO/SLI / error budget / dependency failure / circuit breaker / bulkhead /
load shedding / graceful degradation / overload / cascading failure /
RTO/RPO / failover / restore / reconciliation / resilience testing
  -> rails-reliability-engineering
  -> rails-observability for user-impact telemetry, health, correlation, alerts
  -> rails-performance for workload, saturation, throughput, and capacity evidence
  -> rails-api-integration for timeout/retry/fallback around synchronous dependencies
  -> rails-distributed-systems for cross-service failure, consistency, and recovery
  -> rails-event-driven-messaging for queue lag, retries, DLQ, and consumer capacity
  -> rails-production-runtime for process lifecycle, shutdown, rollout, and recovery
  -> rails-active-job for job retry/concurrency semantics
  -> ruby-concurrency for bounded execution and resource isolation
  -> rails-database-engineering for DB capacity, replicas, locking, and recovery state
  -> rails-security for fail-safe authorization/tenant boundaries
  -> rails-testing for deterministic resilience verification
```

Start with the user-visible reliability objective and failure model. Choose the smallest containment or recovery mechanism that is justified by evidence.

### Reliability pattern selection

| Problem shape | Pattern |
|---|---|
| Define service-level reliability target and budget | pattern:slo-error-budget |
| Classify a dependency's criticality and failure behavior | pattern:dependency-failure-boundary |
| Stop repeated calls into an unhealthy dependency | pattern:circuit-breaker |
| Isolate shared capacity between workloads | pattern:bulkhead-isolation |
| Protect critical work under overload | pattern:load-shedding |
| Preserve useful behavior during dependency failure | pattern:graceful-degradation |
| Define restore/failover/reconciliation targets | pattern:recovery-objectives |
| Verify failure containment and recovery | pattern:resilience-testing |


## Security engineering and threat modeling

```text
threat model / trust boundary / asset / attacker capability /
authorization matrix / tenant isolation / secret management / SSRF /
dependency supply chain / defense in depth / abuse case / residual risk
  -> rails-security-engineering
  -> rails-security for Rails-specific security controls and scanners
  -> rails-authentication for identity/session mechanisms
  -> rails-api-integration for API/webhook/provider boundaries
  -> rails-distributed-systems for cross-service trust and consistency
  -> rails-event-driven-messaging for message trust/replay boundaries
  -> rails-reliability-engineering for failure-safe degradation and recovery
  -> rails-database-engineering for database-enforced invariants
  -> rails-testing for executable security contracts
```

Start from assets and trust boundaries. Use the narrowest existing security control that owns the decision, then add defense in depth only for a distinct failure mode.

### Security pattern selection

| Problem shape | Pattern |
|---|---|
| Formal security architecture review | pattern:threat-model |
| New or changing trust relationship | pattern:trust-boundary |
| Complex role/resource/tenant permissions | pattern:authorization-matrix |
| Cross-tenant access review | pattern:tenant-isolation-review |
| Credential/secret lifecycle | pattern:secret-management-boundary |
| Arbitrary outbound URL/network access | pattern:ssrf-outbound-boundary |
| Gem/CI/build/release dependency risk | pattern:dependency-supply-chain |
| Turn a security finding into durable test coverage | pattern:security-regression |


## Rails incident engineering

```
production incident / incident response / triage / alert / runbook /
diagnostic context / timeline / mitigation / recovery verification /
post-incident review / operational debugging
  -> rails-incident-engineering
  -> rails-observability for telemetry, correlation, error reporting, and health semantics
  -> rails-reliability-engineering for SLI/SLO, failure containment, overload, and recovery objectives
  -> rails-production-runtime for deploy/process lifecycle and rollback mechanics
  -> rails-active-job for job execution/retry state
  -> rails-event-driven-messaging for broker/consumer/replay evidence
  -> rails-distributed-systems for cross-service ownership and consistency
  -> rails-security / rails-security-engineering for secure incident access and trust boundaries
  -> rails-performance when latency, saturation, or capacity evidence is the incident signal
```

Incident response starts from affected user/system contract and evidence, not from the loudest exception. Prefer existing telemetry and reversible mitigation before state-changing intervention.

### Incident pattern selection

| Problem shape | Pattern |
|---|---|
| Establish incident scope, onset, and hypothesis | pattern:incident-triage |
| Create an executable operator procedure | pattern:operational-runbook |
| Make paging signals actionable | pattern:alert-actionability |
| Preserve correlation context across boundaries | pattern:diagnostic-context |
| Build a factual incident timeline | pattern:incident-timeline |
| Debug production safely | pattern:safe-production-debugging |
| Prove recovery beyond process health | pattern:recovery-verification |
| Convert an incident into durable engineering change | pattern:post-incident-review |


## Rails release engineering

```
release readiness / CI-CD release / artifact promotion / release gate /
progressive delivery / canary / staged rollout / environment parity /
rollback / roll-forward / release health / release evidence
  -> rails-release-engineering
  -> rails-deployment for basic hosting/deployment mechanics
  -> rails-production-runtime for process lifecycle, readiness, shutdown, and runtime compatibility
  -> rails-database-engineering for migration/schema compatibility
  -> rails-reliability-engineering for SLI/SLO and recovery objectives
  -> rails-incident-engineering for failed-release operational response
  -> rails-security-engineering for supply-chain/provenance and security-sensitive release controls
  -> rails-api-integration / rails-event-driven-messaging / rails-active-job for cross-boundary compatibility
  -> rails-testing for executable release-contract tests
```

Release engineering owns change propagation and evidence. Reuse existing runtime and deployment primitives instead of creating duplicate release mechanisms.

### Release pattern selection

| Problem shape | Pattern |
|---|---|
| Proportional risk classification | pattern:release-risk-classification |
| Source-to-artifact identity | pattern:artifact-provenance |
| Evidence-backed promotion gate | pattern:deployment-gate |
| Controlled production exposure | pattern:progressive-delivery |
| Staging/production drift | pattern:environment-parity |
| Rollback versus forward recovery | pattern:rollback-rollforward |
| Post-deploy success verification | pattern:release-health-verification |
| Durable release audit trail | pattern:release-evidence |
```


## Rails caching engineering

```
cache key / freshness / invalidation / fragment cache / low-level cache /
response cache / cache store / stampede / hot key / cache warming /
cache failure / eviction / cache capacity / tenant cache isolation
  -> rails-caching
  -> rails-performance for workload, baseline, bottleneck, and re-measurement
  -> ruby-performance for Ruby runtime/cache serialization cost
  -> rails-activerecord for source query and persistence semantics
  -> rails-database-engineering for authoritative state and transaction boundaries
  -> rails-active-job for warming/invalidation work
  -> rails-observability for cache telemetry and diagnostics
  -> rails-security / rails-security-engineering for authorization and tenant isolation
  -> rails-testing for deterministic cache contract tests
```

Caching is a correctness boundary. Define identity, freshness, invalidation, failure, and capacity before optimizing hit rate.

### Cache pattern selection

| Problem shape | Pattern |
|---|---|
| Basic cache correctness boundary | pattern:cache-boundary |
| Tenant/user/authorization key isolation | pattern:cache-key-isolation |
| Domain-owned invalidation | pattern:cache-invalidation-contract |
| Stampede/concurrent recomputation | pattern:cache-stampede-control |
| Cache-store outage/failure semantics | pattern:cache-failure-boundary |
| Bounded prewarming | pattern:cache-warming-strategy |
| Cache capacity/eviction review | pattern:cache-capacity-review |
## Rails Active Support

~~~
Active Support / ActiveSupport / ActiveSupport::Concern /
ActiveSupport::CurrentAttributes / ActiveSupport::Notifications /
ActiveSupport::Callbacks / class_attribute / core extensions /
Active Support instrumentation / Time.zone / safe_constantize /
Active Support inflection / reusable Rails concern
  -> rails-active-support
  -> rails-observability for production telemetry, logging, metrics, health, and diagnostics
  -> ruby-concurrency for thread/fiber safety and context isolation
  -> rails-zeitwerk for autoloading and constant-loading ownership
  -> rails-active-model / rails-activerecord for model-specific callbacks, attributes, and persistence lifecycle
  -> rails-i18n for locale/timezone presentation contracts
  -> rails-security / rails-security-engineering for dynamic constantization, context isolation, and sensitive instrumentation payloads
  -> rails-test-engineering / rails-testing for state-isolated framework tests
~~~

Active Support primitives are framework infrastructure. Keep inherited configuration, request context, callbacks, and instrumentation explicit; do not turn them into hidden global state or domain-event mechanisms.

### Active Support pattern selection

| Problem shape | Pattern |
|---|---|
| Active Support require/load footprint | pattern:active-support-loading-boundary |
| Concern composition/dependencies | pattern:active-support-concern-composition |
| Inherited class configuration | pattern:active-support-class-configuration |
| Request/execution context | pattern:active-support-current-context |
| Custom instrumentation | pattern:active-support-notifications-contract |
| Generic lifecycle callbacks | pattern:active-support-callback-boundary |
| Time/date/timezone semantics | pattern:active-support-time-semantics |
| Inflection/dynamic constantization | pattern:active-support-inflection-boundary |
| State-isolated Active Support tests | pattern:active-support-testing |

## Rails Active Model

~~~
Active Model / ActiveModel / ActiveModel::Model / ActiveModel::API /
ActiveModel::Attributes / ActiveModel::Validations / ActiveModel::Dirty /
ActiveModel::Callbacks / ActiveModel::Serialization / ActiveModel::Translation /
Active Model lint / model-like object / non-persisted model / form model
  -> rails-active-model
  -> ruby-poro / ruby-domain-modeling for domain-object ownership
  -> rails-validations for validation and error semantics
  -> rails-controllers for input boundaries
  -> rails-action-view / rails-views for forms, partials, and rendering
  -> rails-routing for to_param/model_name/form routing when applicable
  -> rails-i18n for translation and locale context
  -> rails-api-integration for serialized external representations
  -> rails-security for authorization/input/output safety
  -> rails-activerecord when persistence/database lifecycle is intrinsic
  -> rails-test-engineering / rails-testing for model protocol and consumer tests
~~~

Active Model is a Rails-facing model protocol, not a substitute for Active Record or a generic service abstraction.

### Active Model pattern selection

| Problem shape | Pattern |
|---|---|
| Decide Active Model versus PORO/Active Record | pattern:active-model-boundary |
| Typed/default transient attributes | pattern:active-model-attributes-contract |
| Non-persisted validation/error contract | pattern:active-model-validation-contract |
| Dirty-state lifecycle | pattern:active-model-dirty-lifecycle |
| Explicit model lifecycle callbacks | pattern:active-model-callback-boundary |
| Form/URL/model conversion semantics | pattern:active-model-conversion-contract |
| Explicit serialization/privacy boundary | pattern:active-model-serialization-contract |
| Deterministic model protocol tests | pattern:active-model-testing |

## Rails Associations

~~~
belongs_to / has_one / has_many / has_many :through / HABTM /
association cardinality / foreign_key / class_name / primary_key /
inverse_of / polymorphic / dependent / destroy_async / nullify /
restrict_with_exception / restrict_with_error / autosave /
nested attributes / counter_cache / touch / before_add / after_add /
before_remove / after_remove / association extension
  -> rails-associations
  -> rails-active-record for Relation/query/materialization semantics
  -> rails-database-engineering for foreign keys, uniqueness, indexes, constraints, migrations, and transaction mechanics
  -> rails-validations for association validation/error behavior
  -> rails-security for authorization and tenant ownership
  -> rails-active-job for supported asynchronous association cleanup
  -> rails-active-storage for attachment cleanup and storage lifecycle
  -> rails-performance for measured association loading and N+1 work
  -> rails-test-engineering / rails-testing for deterministic relationship/lifecycle tests
  -> rails-zeitwerk when namespaced association constants or polymorphic type compatibility cross loader boundaries
~~~

Associations define relationship and lifecycle mechanics, not authorization. Make cardinality, join ownership, inverse behavior, dependent semantics, and loading contracts explicit.

### Association pattern selection

| Problem shape | Pattern |
|---|---|
| Define cardinality and ownership | pattern:association-cardinality-contract |
| Preserve bidirectional/inverse semantics | pattern:association-inverse-contract |
| Join-model relationship and mutation | pattern:through-association-contract |
| Bounded polymorphic targets | pattern:polymorphic-association-boundary |
| Parent/dependent lifecycle | pattern:association-dependent-lifecycle |
| Parent/child persistence coupling | pattern:association-autosave-contract |
| Counter cache/touch coupling | pattern:association-counter-touch-contract |
| Collection mutation callbacks | pattern:association-callback-contract |
| Association loading strategy | pattern:association-loading-contract |
| Relationship regression tests | pattern:association-testing |

## Rails Active Record

~~~
Active Record / ActiveRecord / ApplicationRecord / ActiveRecord::Relation /
query composition / scopes / default_scope / preload / eager_load / includes /
strict_loading / pluck / pick / save / update / destroy / delete /
update_all / delete_all / destroy_all / upsert / after_commit / callbacks
  -> rails-active-record
  -> rails-activerecord for foundational model and persistence guidance
  -> rails-associations for relationship/cardinality/dependent behavior
  -> rails-validations for validation and error semantics
  -> rails-database-engineering for schema, constraints, transactions, locking, isolation, and query-plan mechanics
  -> rails-performance for measured query cost and N+1 investigation
  -> rails-security for tenant/authorization and dynamic-query safety
  -> rails-active-storage for attachment cleanup and storage lifecycle
  -> rails-active-job / rails-event-driven-messaging for durable asynchronous effects
  -> rails-test-engineering / rails-testing for deterministic lifecycle and query tests
~~~

Active Record owns persisted model and Relation semantics. Do not use default_scope, model existence, or callback presence as substitutes for authorization, workflow ownership, or database guarantees.

### Active Record pattern selection

| Problem shape | Pattern |
|---|---|
| Decide model versus service/domain ownership | pattern:active-record-model-boundary |
| Preserve query result/laziness contract | pattern:active-record-query-contract |
| Compose reusable Relations | pattern:active-record-relation-composition |
| Scope/default_scope design | pattern:active-record-scope-contract |
| Save/update/destroy lifecycle | pattern:active-record-persistence-lifecycle |
| Lifecycle and transactional callbacks | pattern:active-record-callback-contract |
| Bulk update/delete/upsert | pattern:active-record-bulk-write-boundary |
| Prevent accidental lazy loading | pattern:active-record-strict-loading |
| Destroy/delete/dependent behavior | pattern:active-record-deletion-contract |
| Query/lifecycle contract tests | pattern:active-record-testing |

## Rails Action Controller

~~~
Action Controller / ActionController / params.expect / strong parameters /
session / cookies / flash / before_action / after_action / around_action /
content negotiation / respond_to / request / response / ETag / Last-Modified /
conditional GET / 304 / streaming / send_data / send_file / rescue_from
  -> rails-action-controller
  -> rails-routing for route declaration and dispatch
  -> rails-controllers for simple action-level design and basic response ownership
  -> rails-authentication for identity/session authentication
  -> rails-security / rails-security-engineering for CSRF, authorization, redirects, tenant isolation, and abuse cases
  -> rails-api-integration for external API and stable wire-contract concerns
  -> rails-observability for request telemetry, error reporting, and correlation
  -> rails-caching for cache identity, invalidation, and shared/private cache correctness
  -> rails-active-storage for attachment/download/storage lifecycle
  -> rails-active-job for asynchronous work delegated from controllers
  -> rails-i18n for locale context
  -> rails-test-engineering / rails-testing for deterministic request and lifecycle tests
~~~

Action Controller owns HTTP request/response mechanics. It should translate transport input, construct the response, and enforce controller lifecycle contracts without becoming the owner of business workflows.

### Action Controller pattern selection

| Problem shape | Pattern |
|---|---|
| Translate HTTP input into an application contract | pattern:action-controller-request-boundary |
| Permit/require nested parameters | pattern:strong-parameters-contract |
| Preserve status/body/header/redirect semantics | pattern:controller-response-contract |
| Session/cookie/flash lifecycle | pattern:controller-session-cookie-boundary |
| Callback scope and lifecycle | pattern:action-controller-callback-contract |
| Multiple response formats | pattern:controller-content-negotiation |
| ETag/Last-Modified conditional responses | pattern:conditional-response-cache |
| Large downloads/streaming | pattern:controller-streaming-download |
| Expected exception to HTTP mapping | pattern:controller-exception-boundary |
| Deterministic controller contract tests | pattern:action-controller-testing |

## Rails Action View

~~~
Action View / ActionView / view rendering / templates / partials / layouts /
strict locals / locals signature / helper boundary / output safety / html_safe /
raw HTML / sanitize / localized views / collection rendering / view performance
  -> rails-action-view
  -> rails-views for basic presentation responsibilities, template organization, and forms
  -> rails-controllers for render/redirect/content negotiation and response ownership
  -> rails-i18n for locale context, fallback, and localization policy
  -> rails-caching for fragment/collection cache identity and invalidation
  -> rails-performance / ruby-performance for measured rendering/query/allocation work
  -> rails-security / rails-security-engineering for escaping, sanitization, XSS, authorization, and cache privacy
  -> rails-action-text for persisted rich content and attachment rendering
  -> rails-test-engineering / rails-testing for deterministic rendering and security tests
~~~

Action View owns response rendering, not business authorization or persistence. Treat templates, partials, layouts, helpers, and rendered HTML as explicit contracts.

### Action View pattern selection

| Problem shape | Pattern |
|---|---|
| Reusable partial inputs and locals | pattern:action-view-partial-contract |
| Stable partial local signature | pattern:action-view-strict-locals |
| HTML escaping/sanitization/output safety | pattern:action-view-output-safety |
| Layout selection/content slots | pattern:action-view-layout-contract |
| Presentation helper responsibility | pattern:action-view-helper-boundary |
| Rendering bottleneck investigation | pattern:action-view-render-performance |
| Locale-specific template selection | pattern:action-view-localized-template |
| Deterministic rendering/security tests | pattern:action-view-testing |

## Rails Action Mailer

```text
Action Mailer / ApplicationMailer / mailer / email delivery /
deliver_later / deliver_now / mailer preview / SMTP / provider /
email security / email observability
  -> rails-action-mailer
  -> rails-active-job for asynchronous delivery, retries, queue, idempotency, and transaction semantics
  -> rails-api-integration for HTTP email providers and provider adapters
  -> rails-security / rails-security-engineering for recipient, tenant, token, secret, and privacy boundaries
  -> rails-observability for delivery telemetry and correlation
  -> rails-test-engineering / rails-testing for deterministic mailer and async tests
  -> rails-distributed-systems for ambiguous provider outcomes and durable delivery state
```

Action Mailer is an external side-effect boundary. Keep eligibility, authorization, and durable business state outside templates.

### Action Mailer pattern selection

| Problem shape | Pattern |
|---|---|
| Define message contract | pattern:mailer-contract |
| Choose synchronous/asynchronous semantics | pattern:mailer-delivery-semantics |
| Isolate SMTP/API provider behavior | pattern:mailer-provider-boundary |
| Review email privacy/authorization | pattern:mailer-security-boundary |
| Test mail contracts and delivery behavior | pattern:mailer-testing |
| Instrument delivery lifecycle | pattern:mailer-observability |
## Rails Active Storage

```text
Active Storage / ActiveStorage / has_one_attached / has_many_attached /
file upload / direct upload / storage service / blob / attachment /
file serving / signed blob URL / variant / preview / analysis / purge /
storage mirror / storage migration
  -> rails-active-storage
  -> rails-security / rails-security-engineering for upload authorization, tenant isolation, file access, and untrusted content
  -> rails-active-job for analysis, variants, purge jobs, retries, and worker lifecycle
  -> rails-api-integration when provider-specific HTTP/storage adapters exist
  -> rails-performance / ruby-performance for download and transformation capacity
  -> rails-caching for CDN/proxy/cache isolation decisions
  -> rails-observability for storage/processing telemetry
  -> rails-production-runtime for worker/process capacity
  -> rails-test-engineering / rails-testing for deterministic attachment and access tests
```

Active Storage is an external-data boundary. The domain resource owns authorization; the blob is not itself the authorization boundary.

### Active Storage pattern selection

| Problem shape | Pattern |
|---|---|
| Attachment ownership/lifecycle | pattern:active-storage-boundary |
| Upload security and tenant isolation | pattern:active-storage-upload-security |
| Browser direct upload lifecycle | pattern:active-storage-direct-upload |
| File serving/private access/CDN | pattern:active-storage-serving |
| Analysis/variants/previews | pattern:active-storage-processing |
| Deletion/purge/orphan cleanup | pattern:active-storage-purge |
| Deterministic Active Storage tests | pattern:active-storage-testing |
## Rails Action Cable

```text
Action Cable / ActionCable / WebSocket / realtime /
ApplicationCable::Connection / ApplicationCable::Channel /
subscription / stream_from / stream_for / broadcast_to /
Redis pubsub / reconnect / resubscribe / realtime capacity
  -> rails-action-cable
  -> rails-security / rails-security-engineering for connection auth, channel authorization, origins, tenant isolation, and sensitive payloads
  -> rails-active-job for asynchronous producers and background lifecycle
  -> rails-event-driven-messaging / rails-distributed-systems when realtime messages depend on durable events, outbox, replay, or cross-process delivery
  -> rails-reliability-engineering for failure/degradation and overload controls
  -> rails-performance / ruby-performance / ruby-concurrency for fan-out, serialization, memory, and connection capacity
  -> rails-production-runtime / rails-release-engineering for process lifecycle, deploy/reconnect behavior, and topology
  -> rails-observability for connection/broadcast telemetry
  -> rails-test-engineering / rails-testing for deterministic connection/channel/broadcast tests
```

Action Cable is an online realtime boundary, not a durable message queue. Authorization belongs at both the connection and channel/resource boundaries.

### Action Cable pattern selection

| Problem shape | Pattern |
|---|---|
| WebSocket identity/authentication | pattern:action-cable-connection-auth |
| Per-resource/channel authorization | pattern:action-cable-channel-authorization |
| Stream naming and isolation | pattern:action-cable-stream-contract |
| Payload/schema compatibility | pattern:action-cable-broadcast-contract |
| Missed updates/reconnect reconciliation | pattern:action-cable-reconciliation |
| Connection/fan-out capacity | pattern:action-cable-capacity |
| Redis/cable outage behavior | pattern:action-cable-failure-boundary |
| Deterministic realtime tests | pattern:action-cable-testing |
## Rails I18n

```text
I18n / internationalization / localization / locale / translations /
I18n.t / I18n.l / available_locales / default_locale / pluralization /
interpolation / localized routes / locale negotiation / missing translation
  -> rails-i18n
  -> rails-routing / rails-views / rails-validations for URL, rendering, and validation presentation
  -> rails-api-integration for localized wire/error contracts
  -> rails-action-mailer for localized subjects/content
  -> rails-active-job for background locale propagation
  -> rails-caching for locale-sensitive cache identity
  -> rails-security for locale input, translated HTML, interpolation, and translation administration
  -> rails-test-engineering / rails-testing for deterministic locale isolation and translation tests
  -> ruby-concurrency when locale crosses custom execution-context boundaries
```

I18n is a cross-layer presentation contract. Locale is presentation context, not authorization.

### I18n pattern selection

| Problem shape | Pattern |
|---|---|
| Resolve locale from multiple sources | pattern:i18n-locale-resolution |
| Stable translation keys/interpolation | pattern:i18n-translation-key-contract |
| Pluralization/date/number formatting | pattern:i18n-pluralization-formatting |
| Locale-aware URLs/routes | pattern:i18n-localized-routing |
| Background/asynchronous locale context | pattern:i18n-context-propagation |
| Locale-sensitive cache identity | pattern:i18n-cache-identity |
| Localization security/privacy | pattern:i18n-security-boundary |
| Deterministic localization tests | pattern:i18n-testing |
## Rails Action Mailbox

~~~
Action Mailbox / ActionMailbox / inbound email / InboundEmail /
ApplicationMailbox / mailbox routing / email ingress / provider webhook /
relay ingress / bounce_with / receive email / inbound email replay
  -> rails-action-mailbox
  -> rails-api-integration for provider ingress/webhook contracts and adapter boundaries
  -> rails-security / rails-security-engineering for ingress trust, sender identity, authorization, tenant isolation, and untrusted email content
  -> rails-active-job for asynchronous mailbox processing, retries, queues, idempotency, and transaction-aware follow-up work
  -> rails-active-storage for raw email source and attachment lifecycle
  -> rails-action-mailer for outbound replies and bounce notices
  -> rails-database-engineering for durable idempotency, transaction ownership, constraints, and retention state
  -> rails-event-driven-messaging / rails-distributed-systems for outbox, inbox, replay, or cross-service workflows
  -> rails-observability for correlation, lifecycle telemetry, error reporting, and sensitive-data filtering
  -> rails-reliability-engineering / rails-incident-engineering for backlog, poison-message containment, recovery, and operator replay
  -> rails-test-engineering / rails-testing for deterministic mailbox/ingress tests
~~~

Action Mailbox is an inbound trust and side-effect boundary. Keep ingress authentication, sender identity, recipient routing, tenant authorization, and business idempotency as separate decisions.

### Action Mailbox pattern selection

| Problem shape | Pattern |
|---|---|
| External provider/MTA ingress | pattern:action-mailbox-ingress-boundary |
| Recipient routing and precedence | pattern:action-mailbox-routing-contract |
| Sender/provider trust and tenant security | pattern:action-mailbox-authenticity-security |
| Duplicate delivery/replay safety | pattern:action-mailbox-idempotency |
| Mailbox callbacks and processing lifecycle | pattern:action-mailbox-processing-lifecycle |
| Tenant/resource ownership | pattern:action-mailbox-tenant-association |
| Poison message/quarantine/recovery | pattern:action-mailbox-failure-quarantine |
| Deterministic mailbox tests | pattern:action-mailbox-testing |

## Rails Action Text

```text
Action Text / ActionText / has_rich_text / RichText / Trix /
rich_textarea / rich text / action-text-attachment / Signed Global ID /
attachable / rich text rendering / rich text API / Action Text N+1
  -> rails-action-text
  -> rails-views / rails-activerecord / rails-validations for rendering, ownership, persistence, and input contracts
  -> rails-active-storage for embedded file upload/storage/access lifecycle
  -> rails-security / rails-security-engineering for sanitization, attachable authorization, tenant isolation, and XSS
  -> rails-i18n for locale-aware rich content and surrounding presentation
  -> rails-caching for rendered-content identity and private-content isolation
  -> rails-performance / ruby-performance for RichText preloading and rendering capacity
  -> rails-api-integration for stable rich-text API representations
  -> rails-active-job for asynchronous processing/indexing/cleanup
  -> rails-test-engineering / rails-testing for deterministic rich-text, attachment, and security tests
```

Action Text is a persisted rich-content boundary. Sanitization does not replace authorization of embedded resources or attachables.

### Action Text pattern selection

| Problem shape | Pattern |
|---|---|
| Define rich-text ownership/content contract | pattern:action-text-content-contract |
| Sanitization/XSS/link safety | pattern:action-text-sanitization-security |
| Embedded resource/file authorization | pattern:action-text-attachment-authorization |
| Safe HTML/plain-text rendering | pattern:action-text-rendering |
| Stable API representation | pattern:action-text-api-boundary |
| RichText/embed N+1 and performance | pattern:action-text-preload-performance |
| RichText/attachment lifecycle | pattern:action-text-lifecycle |
| Signed Global ID attachables | pattern:action-text-attachable-contract |
| Deterministic Action Text tests | pattern:action-text-testing |

### Validation engineering

validation rule / context / error / custom validator / bypass path
  -> rails-validations
  -> rails-active-record or rails-active-model
  -> rails-database-engineering when invariants must survive concurrency
  -> rails-associations for owned associated validation
  -> rails-action-controller / rails-action-view / rails-api-integration for boundary contracts
  -> rails-i18n for translated errors
  -> rails-security for tenant and disclosure boundaries
  -> rails-test-engineering / rails-testing for deterministic contract tests

### Validation pattern selection

| Problem shape | Pattern |
|---|---|
| Invariant ownership across model/database boundaries | pattern:validation-boundary |
| Named validation operation/context | pattern:validation-context-contract |
| Conditional validation predicate | pattern:validation-condition-contract |
| Concurrent/scoped uniqueness | pattern:validation-uniqueness-database-contract |
| Bounded associated validation | pattern:validation-associated-graph |
| Reusable validation rule | pattern:validation-custom-validator |
| Fail-fast invalid state | pattern:validation-strict-failure |
| Stable validation error representation | pattern:validation-error-contract |
| Validation lifecycle callback | pattern:validation-callback-boundary |
| Direct/bulk write bypass review | pattern:validation-bypass-audit |
| Deterministic validation tests | pattern:validation-testing |
