# Request, integration, system, job, and mail tests

Reference for the `rails-test-engineering` skill. Load it on demand when testing requests, browser flows, Active Job enqueue/perform, or mailers and external side effects. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Request and integration tests
Request/integration tests should exercise routing, parameters, authentication, controller behavior, persistence, and response contracts when those layers are part of the requirement.

Prefer request-level tests for externally observable HTTP behavior rather than directly testing controller implementation.

For a request test, assert the minimum stable contract:
request
-> status
-> response shape/body
-> important persistence or side effect
-> authorization

Rails integration tests are intended for workflows that cross multiple components.

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

Rails provides system test support and screenshot helpers for failures.

## Active Job testing
Test jobs at two boundaries when both matter:

caller
-> job was enqueued correctly

job itself
-> execution produced the required result

Use ActiveJob::TestHelper assertions for queueing behavior and perform_enqueued_jobs when you want the test adapter to actually execute enqueued work.

Rails documents that the test adapter does not execute jobs until perform_enqueued_jobs is invoked and that the queue is cleared between tests. It also recommends perform_later plus perform_enqueued_jobs when testing retry-aware execution because direct perform bypasses some framework behavior.

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
