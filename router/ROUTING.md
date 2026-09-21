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
| Rails view/form | rails-views | rails-controllers, rails-testing |
| Model/migration/query | rails-activerecord | rails-architecture, rails-testing |
| Active Record association | rails-associations | rails-activerecord, rails-testing |
| Validation/invariant | rails-validations | rails-activerecord, rails-testing |
| Authentication/session | rails-authentication | rails-controllers, rails-testing |
| Rails test design | rails-testing | relevant implementation skill, ruby-tdd-refactoring |
| Rails generator/scaffold | rails-generators | relevant Rails skill, rails-testing, pattern:scaffold-lifecycle |\n| Rails REST resource | rails-routing | rails-controllers, rails-authentication, rails-testing, pattern:rest-resource |
| Rails deployment/hosting | rails-deployment | rails-architecture, ruby-debugging |
| Rails performance/scalability | rails-performance | ruby-performance, rails-activerecord, rails-database-engineering, rails-active-job, rails-observability, ruby-concurrency, rails-testing |
| Rails API and integration architecture | rails-api-integration | rails-routing, rails-controllers, rails-authentication, rails-security, rails-observability, rails-active-job, ruby-api-design, ruby-gems-io-services, ruby-dependency-injection, rails-testing |
| Distributed systems and service architecture | rails-distributed-systems | rails-api-integration, rails-active-job, rails-database-engineering, ruby-concurrency, rails-observability, rails-production-runtime, rails-security, rails-testing |
| Event-driven messaging architecture | rails-event-driven-messaging | rails-distributed-systems, rails-active-job, rails-api-integration, rails-observability, rails-production-runtime, ruby-concurrency, rails-security, rails-testing |
| Reliability engineering and resilience | rails-reliability-engineering | rails-observability, rails-performance, rails-api-integration, rails-distributed-systems, rails-event-driven-messaging, rails-production-runtime, rails-active-job, ruby-concurrency, rails-database-engineering, rails-security, rails-testing |
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
```
