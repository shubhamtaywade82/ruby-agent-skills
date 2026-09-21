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
