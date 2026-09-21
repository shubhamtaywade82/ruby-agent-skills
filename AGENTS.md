# Agent Engineering Contract

This repository is an agent-oriented Ruby/Rails skill library. Every coding agent working here must treat the skill library, pattern library, evaluation corpus, and validators as one system.

## Operating sequence

1. **Discover** the applicable repository skills from `skill-manifest.yml`.
2. **Inspect** the repository, current implementation, tests, runtime/version constraints, and existing conventions before proposing a design.
3. **Resolve ambiguity** before changing code. Do not silently choose between conflicting requirements.
4. **Select patterns only when earned.** Existing repository patterns take precedence over generic preferences. A pattern is guidance, not a mandatory abstraction.
5. **Implement incrementally** in the smallest coherent slice.
6. **Test behavior** at the boundary that owns the contract.
7. **Lint the change** with the repository's RuboCop configuration when Ruby/Rails code is affected.
8. **Run security verification** for security-sensitive Ruby/Rails changes, using the configured scanners and abuse-case tests.
9. **Review the change** for correctness, simplicity, architecture, security, performance, and scope.
10. **Simplify** if an abstraction does not earn its complexity.
11. **Verify** with the repository's validators, focused tests, and applicable CI-equivalent checks.
12. **Report evidence**, not assumptions. Never claim a test, benchmark, CI run, or deployment passed unless it was actually observed.

## Context rules

- Read only the smallest useful source slice first; expand context when evidence requires it.
- Resolve Ruby/Rails versions from repository configuration rather than memory.
- Prefer official/source-backed guidance for framework-sensitive behavior.
- Treat `.rubocop.yml` as the executable Ruby/Rails style baseline; inspect plugin applicability before interpreting findings.
- Treat security scanner output as evidence requiring trust-boundary/data-flow analysis, not as an automatic verdict.
- Treat external input and third-party responses as untrusted at boundaries.
- Never weaken a validator or test merely to make an agent run green.
- Preserve public contracts unless the task explicitly changes them.

## Design rules

- Prefer the simplest implementation satisfying the contract.
- Reuse an existing repository abstraction before introducing a new one.
- Introduce POROs, services, strategies, adapters, policies, presenters, factories, or other patterns only when the responsibility or variation justifies the boundary.
- Keep domain behavior out of controllers/views when it does not belong there.
- Keep persistence integrity in database constraints where application validation alone cannot guarantee it.
- Do not create abstractions solely to satisfy a pattern vocabulary.

## Verification contract

A change is complete only when:
- relevant tests pass;
- validators pass;
- no accidental scope expansion is present;
- public contracts are preserved or intentionally updated;
- unrun checks are explicitly disclosed.

## Skill precedence

When multiple skills apply:

1. explicit task requirements
2. repository architecture and existing conventions
3. runtime/framework constraints
4. focused domain skill
5. design-pattern guidance
6. generic style preferences

When skills conflict, stop and resolve the conflict rather than combining incompatible rules.

## Benchmark integrity

Evaluation fixtures and verifiers are measurement infrastructure. Do not make the evaluator easier by weakening constraints, accepting unverified output, or coupling the verifier to one agent's implementation. Public structural checks must be complemented by behavioral tests and, where appropriate, hidden/adversarial cases.


## Performance-sensitive changes

For performance work:
- establish a workload and baseline before optimizing when practical;
- distinguish latency, throughput, CPU, allocations, GC, database, network, and contention costs;
- use profiling/benchmarking only to answer a concrete question;
- never claim a performance improvement without measurement or a demonstrated structural property;
- do not introduce caching without explicit freshness and invalidation semantics;
- do not increase concurrency without downstream capacity analysis;
- keep performance thresholds stable enough for CI.


## Zeitwerk/autoloading changes

For Ruby/Rails constants and file-layout changes:
- resolve the loader/runtime version first;
- verify path-to-constant and namespace ownership;
- inspect inflections and autoload roots;
- distinguish reloadable and once-loaded code;
- check initializer lifecycle;
- run Zeitwerk/eager-load verification when available;
- do not hide structural loading errors with arbitrary require/require_dependency calls.


## Active Job/background-job changes

For background-job changes:
- resolve the Rails/Active Job/queue-adapter versions first;
- inspect ApplicationJob and existing job conventions;
- make serialization and idempotency explicit;
- classify retryable versus permanent failures;
- inspect transaction/commit semantics when enqueueing from database transactions;
- analyze concurrency and downstream capacity;
- verify queue/worker configuration and shutdown behavior when operational behavior changes;
- test enqueue, perform, failure, retry/discard, and duplicate-execution behavior as applicable.


## Rails request lifecycle/observability changes

For request and production-diagnostics changes:
- resolve Rails version first;
- inspect existing HTTP error, logging, request-ID, and health conventions;
- keep exception-to-response mappings narrow;
- preserve correlation identifiers across request/job/dependency boundaries;
- filter sensitive data before logs/error context;
- use Rails.error for error reporting and ActiveSupport::Notifications for meaningful instrumentation;
- keep instrumentation subscribers observational;
- distinguish liveness from readiness and dependency health;
- verify request/error/health contracts with focused tests.


## Rails database/schema changes

For database changes:
- resolve Rails, adapter, and database versions first;
- inspect schema, existing indexes/constraints, data volume, and deployment order;
- treat migrations as rolling-deployment contracts;
- separate expand/backfill/cutover/contract when compatibility requires it;
- preserve database invariants with constraints where the database is the authoritative writer boundary;
- use bounded/idempotent backfills;
- make transaction, locking, isolation, and deadlock semantics explicit;
- size connection pools against aggregate application concurrency and database limits;
- require query-plan evidence for query/index performance claims;
- test migration and database behavior at the owning boundary.
