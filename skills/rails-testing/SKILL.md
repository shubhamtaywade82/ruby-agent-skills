---
name: rails-testing
description: Use when adding or changing Rails behavior and deciding where model, request, system, controller, service, or integration tests should live.
---

# Rails Testing

## Purpose

Place tests at the boundary that owns the behavior and use integration tests where the contract crosses Rails layers.

## Activate when

- adding/changing Rails behavior
- fixing a Rails bug
- modifying a model/controller/request flow
- adding authentication or authorization
- changing rendered user-visible behavior
- reviewing test quality

## Repository inspection

Resolve:

- RSpec or Minitest
- unit/model conventions
- request/controller tests
- system tests
- factories/fixtures
- test database setup
- helper/shared examples
- CI commands
- external-service stubs/fakes

Reuse the project's ecosystem.

## Test placement

Prefer the smallest useful test that proves the contract.

Examples:

- model invariant -> model test
- association behavior -> model/integration test as appropriate
- service workflow -> service/domain test
- HTTP response contract -> request test
- user interaction -> system test when the repository uses one
- cross-layer authentication -> request/integration test

A focused test and an end-to-end test may both be justified when they prove different contracts.

## Test design

Tests should explain behavior.

Prefer:

```text
setup
  -> meaningful action
  -> meaningful expectation
```

over large arrangements with opaque helpers.

Cover:

- normal cases
- edge cases
- invalid input
- authorization/authentication
- error behavior
- important side effects
- regressions

## Determinism

Avoid unnecessary:

- sleeps
- time dependence
- random data without controlled seed
- external network calls
- ordering assumptions
- shared mutable state

Use time helpers/fakes consistent with repository conventions.

## Mocking/stubbing

Mock external boundaries when appropriate, not the implementation under test.

Avoid mocking every internal method; that can make tests pass while behavior is broken.

## Regression tests

A bug fix should ideally add a test that represents the previous failure.

## Agent review checklist

- [ ] test stack and conventions inspected
- [ ] test boundary matches behavior
- [ ] assertions describe the contract
- [ ] edge/failure cases considered
- [ ] external boundaries isolated appropriately
- [ ] tests deterministic
- [ ] no unnecessary implementation coupling

## Verification

Run focused tests first, then the affected Rails test group, then broader CI-equivalent checks where appropriate.

## Source foundation

Combines Rails testing practice implicit in the application activities of *The Ruby Workshop* with the TDD/test readability guidance in *Clean Ruby*, including meaningful test descriptions and focused expectations.

## Book integration: request-level testing

For HTTP behavior that crosses routing, controller, persistence, authentication, and response layers, prefer request-level tests over tests that exercise only an isolated controller implementation when the repository's test stack supports that style.

A request test should assert the observable contract: status, response body/redirect, persistence/side effects, and relevant authorization behavior.

Keep unit/service tests for local behavior and request/system tests for cross-layer contracts.
