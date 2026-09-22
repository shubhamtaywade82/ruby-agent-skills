---
name: rails-test-engineering
description: Use when designing, reviewing, debugging, optimizing, or scaling a Rails test suite across unit, model, request, integration, system, job, mailer, Action Cable, parallel, and CI boundaries.
---

# Rails Test Engineering

## Purpose
Treat the test suite as an engineered system with contracts for behavior, isolation, determinism, speed, parallel safety, and production-relevant confidence.

Core model:

test boundary
-> arrange controlled state
-> execute real contract
-> assert observable behavior
-> isolate external dependencies
-> clean state
-> run deterministically
-> integrate into CI

Primary current Rails references:
- https://guides.rubyonrails.org/testing.html
- https://guides.rubyonrails.org/active_job_basics.html

## Activate when
- choosing or reviewing model/request/integration/system/job tests
- changing test helpers, fixtures, factories, or test database setup
- diagnosing flaky tests
- enabling or tuning parallel tests
- changing transactional test behavior
- testing asynchronous jobs/mailers
- testing time-dependent behavior
- adding system/browser tests
- changing external-service stubs/fakes
- measuring slow tests or test-suite boot time
- reviewing CI test coverage
- introducing a second test framework or test library
- testing reload/eager-load behavior

## Repository inspection
Inspect:
1. test framework: Minitest, RSpec, or another stack;
2. test directory conventions;
3. test_helper and shared helpers;
4. fixtures/factories/builders;
5. transactional test configuration;
6. database-cleaning strategy;
7. request/system/job/mailbox/channel test conventions;
8. external HTTP/service stubs;
9. time helpers;
10. CI commands and parallelization;
11. test environment configuration;
12. eager-load configuration in CI;
13. current test runtime and flaky-test history when available.

Do not introduce factories, VCR-like tools, a second test framework, or custom cleaning infrastructure until existing repository conventions are understood.

## Test boundary selection
Use the smallest boundary that proves the behavior:

model/domain invariant
-> model/domain test

service/application workflow
-> focused service/domain test

HTTP contract
-> request/integration test

cross-controller workflow
-> integration test

real user/browser interaction
-> system test

job behavior
-> ActiveJob::TestCase

job enqueue from caller
-> caller test with ActiveJob::TestHelper

mail delivery behavior
-> mailer test plus request/system coverage when triggered by user behavior

Action Cable protocol
-> connection/channel tests and broadcast assertions

Use more than one level when the tests prove different contracts. Do not duplicate the same assertion at every layer merely for coverage count.

Rails' current testing guide distinguishes unit/model, functional, integration, system, job, mailer, Action Cable, and other test types. Integration tests are intended for interactions between multiple application components, while system tests exercise the application as a user would. citeturn337423view0turn943311view0

## Contract-focused assertions
Prefer assertions on externally meaningful outcomes:
- response status/body/redirect;
- persisted state;
- emitted/enqueued work;
- authorization result;
- broadcast/message;
- published event;
- visible UI behavior;
- exception type when the exception is itself the contract.

Avoid asserting incidental implementation details such as private method calls, internal collaborator ordering, or exact SQL unless those details are explicitly part of the contract.

## Fixtures, factories, and builders
Use the repository's existing data construction strategy.

Fixtures are appropriate when the repository values stable shared reference data or when test data is mostly declarative.

Factories/builders can be useful when data variations are numerous, but avoid creating deeply nested defaults that hide the actual state under test.

Prefer explicit attributes for behaviorally important data.

A test should make the meaningful precondition visible without requiring the reader to understand an entire factory graph.

Do not use factories as a substitute for domain invariants.

## Database isolation
Rails test applications normally run against the test environment and provide transactional test support.

Default to transactional isolation where it proves the behavior and the application does not require multiple concurrent database connections that conflict with the test transaction.

When testing concurrent transactions, threads/processes that need independent connections, or behavior involving committed state, inspect whether transactional tests must be disabled for that test case.

Rails documents that parallel transaction tests can block when nested under implicit test transactions and shows disabling transactional tests for that class. Cleanup then becomes the test's responsibility. citeturn332644view0

Do not globally disable transactional tests to fix one concurrency test.

## Request and integration tests
Request/integration tests should exercise routing, parameters, authentication, controller behavior, persistence, and response contracts when those layers are part of the requirement.

Prefer request-level tests for externally observable HTTP behavior rather than directly testing controller implementation.

For a request test, assert the minimum stable contract:
request
-> status
-> response shape/body
-> important persistence or side effect
-> authorization

Rails integration tests are intended for workflows that cross multiple components. citeturn943311view0

## System tests
System tests exercise the application from the user's perspective, including browser interaction and JavaScript behavior.

Use them when the contract depends on:
- browser interaction;
- JavaScript;
- navigation/focus/modal behavior;
- client-visible asynchronous UI;
- full authentication/session flows;
- rendering and browser integration.

Do not turn every request test into a browser test. System tests are slower and should protect user journeys that cannot be proven reliably lower in the stack.

Rails provides system test support and screenshot helpers for failures. citeturn943311view1

## Active Job testing
Test jobs at two boundaries when both matter:

caller
-> job was enqueued correctly

job itself
-> execution produced the required result

Use ActiveJob::TestHelper assertions for queueing behavior and perform_enqueued_jobs when you want the test adapter to actually execute enqueued work.

Rails documents that the test adapter does not execute jobs until perform_enqueued_jobs is invoked and that the queue is cleared between tests. It also recommends perform_later plus perform_enqueued_jobs when testing retry-aware execution because direct perform bypasses some framework behavior. citeturn943311view2

Use direct perform only when the test intentionally needs to assert an exception path that framework job execution would intercept, and document that trade-off.

Never verify a job integration solely by calling perform directly.

## Mailers and external side effects
Separate:

email composition
-> mailer test

email enqueueing
-> caller/job test

user workflow
-> request/system test

External HTTP APIs:
- stub at the external boundary;
- assert request shape and relevant responses;
- avoid mocking your own internal domain behavior merely to make the test fast;
- provide explicit failure scenarios.

Do not let ordinary unit tests call production third-party endpoints.

## Determinism
A deterministic test should not depend on:
- sleep durations;
- wall-clock time;
- random values without controlled seeds;
- global mutable state;
- test execution order;
- network availability;
- machine-specific filesystem layout;
- implicit timezone assumptions;
- leftover database records.

Use Rails time helpers such as travel_to when the behavior depends on current time. Rails documents ActiveSupport::Testing::TimeHelpers for this purpose. citeturn332644view0

Prefer condition-driven synchronization over sleeps.

## Parallel test safety
Rails supports parallel testing with processes by default and also supports threads. The number of workers can be configured directly or via PARALLEL_WORKERS. Rails creates separate test databases for process workers. citeturn332644view0

Before enabling or increasing parallelism, audit:
- global mutable state;
- shared filesystem paths;
- fixed ports;
- external test doubles;
- cache state;
- singleton registries;
- sequence assumptions;
- database connection capacity;
- non-transactional tests.

Never make a flaky suite green by reducing parallelism without identifying the isolation defect.

When thread parallelism is used, inspect thread safety and database connection behavior. Use ruby-concurrency for the underlying concurrency analysis.

## Parallel database tests
Parallel test workers require database capacity and isolation.

Check:

test workers
×
connections per worker
≤
test database/server capacity

When multiple databases/shards/roles are configured, verify worker setup for each one.

Rails exposes parallelize_setup and parallelize_teardown hooks for process-based parallel test setup when needed. citeturn332644view0

## Test parallelization threshold
Parallelization has startup/database/fixture overhead.

Do not force parallel execution for tiny suites. Rails itself has a configurable threshold and currently avoids parallelizing suites below the default threshold. citeturn332644view0

Benchmark before changing threshold values.

## Flaky test diagnosis
Treat flakiness as a reproducibility problem.

Capture:
- exact test name;
- random seed;
- retry count;
- execution mode;
- parallel worker/thread configuration;
- environment/runtime versions;
- relevant logs;
- database state assumptions;
- network/time dependencies.

Then classify the source:

timing race
state leakage
order dependence
database transaction mismatch
parallel resource collision
timezone/clock issue
randomness
external dependency
environment/boot issue

Do not immediately add retries around flaky tests.

A retry can provide diagnostic information, but it does not prove the test is fixed.

## Test order
Tests should remain order-independent unless ordering is explicitly part of the contract.

Use randomized order where supported and investigate failures under the reported seed.

Never rely on a previous test to populate state used by a later test.

## Time and timezone
For time-sensitive behavior, control time explicitly.

Test both:
- application time zone;
- UTC/database serialization behavior where relevant.

Do not hard-code the machine's current timezone into tests.

Use boundary dates/times for daylight-saving-sensitive behavior where the application supports multiple time zones.

## Test performance
Treat test runtime as engineering capacity.

Measure separately:
- test boot time;
- database setup time;
- fixture/factory cost;
- individual slow tests;
- system test cost;
- parallel coordination overhead.

Optimize only after measurement.

Common high-value changes include:
- narrowing a broad integration test;
- reducing factory graph depth;
- removing unnecessary eager helper loading;
- using targeted fixtures;
- parallelizing only sufficiently large suites;
- avoiding real external I/O;
- reducing redundant system tests.

Rails warns that eagerly requiring all test helpers increases boot time compared with requiring only needed helpers. citeturn943311view1

Do not optimize by weakening assertions or removing coverage without an explicit contract decision.

## CI strategy
CI should prove more than local unit tests.

A robust pipeline typically separates:

fast focused tests
-> full application tests
-> system/browser tests
-> eager-load verification
-> lint/security/static checks

Rails documents that bin/rails test does not run system tests by default; bin/rails test:system or bin/rails test:all can include them. Rails also documents eager loading during CI as a way to detect load failures before production. citeturn332644view0

Use repository-specific CI commands rather than assuming these exact commands apply.

## Eager-loading test
When Rails code is sensitive to autoloading structure, CI should exercise eager loading where practical.

Rails documents enabling eager loading in CI and also provides an explicit Rails.application.eager_load! test pattern. citeturn332644view0

Pair this with rails-zeitwerk rather than duplicating loader rules in tests.

## Test doubles
Use doubles to control real external boundaries:
- HTTP API
- payment gateway
- email transport
- clock when the repository cannot use Rails time helpers
- filesystem/process boundary
- message broker.

Do not mock the model/service under test solely to assert that an internal method was called.

A fake should have behavior relevant to the contract and should fail loudly when an unexpected operation occurs.

## Contract and integration tests
When an external boundary has a stable protocol, add a focused contract test for the request/response schema.

Do not duplicate a full end-to-end suite for every external dependency.

Use integration tests to prove real component collaboration and unit tests to isolate local rules.

## Test anti-patterns
- sleep-based synchronization
- global disable of transactional tests
- retrying flaky tests until CI turns green
- direct job.perform as the only job test
- controller tests for HTTP contracts when request tests are available
- system tests for every unit-level rule
- mocking every collaborator
- factories with hidden business state
- tests depending on order
- hard-coded local time zone
- shared fixed ports/files
- broad helper globbing without boot-time measurement
- parallelizing stateful tests without isolation
- deleting assertions to reduce runtime

## Agent review checklist
- [ ] test framework/conventions identified
- [ ] smallest owning test boundary selected
- [ ] request/system/job layering is deliberate
- [ ] fixtures/factories are explicit and bounded
- [ ] database isolation is understood
- [ ] time is deterministic
- [ ] external boundaries are isolated
- [ ] parallel safety is considered
- [ ] flaky behavior is investigated rather than retried blindly
- [ ] test runtime is measured before optimization
- [ ] CI includes the required test classes
- [ ] eager loading is verified when relevant
- [ ] tests assert contracts instead of incidental implementation

## Verification
Run focused tests first, then the affected suite, then broader CI-equivalent checks. When changing parallelization, transactional tests, system tests, job testing, or test infrastructure, verify the runtime behavior of the test system itself.

## Rails 8.1 current framework considerations

- Rails 8.1 provides Local CI through `config/ci.rb` and `bin/ci`. Treat local CI as part of the repository's executable verification contract when present.
- Keep local and hosted CI commands aligned on security checks, test setup, and required gates; avoid having `bin/ci` silently exercise a weaker contract than the hosted workflow.

## Source foundation
Primary source: Rails Testing Applications guide: https://guides.rubyonrails.org/testing.html
Supporting source: Rails Active Job Basics: https://guides.rubyonrails.org/active_job_basics.html
Framework version notes must be resolved from the target repository and installed Rails version.