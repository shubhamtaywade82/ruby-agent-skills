# Assertions, test data, database isolation, and doubles

Reference for the `rails-test-engineering` skill. Load it on demand when writing assertions, fixtures, factories, or builders, isolating database state, or introducing test doubles. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

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

Rails documents that parallel transaction tests can block when nested under implicit test transactions and shows disabling transactional tests for that class. Cleanup then becomes the test's responsibility.

Do not globally disable transactional tests to fix one concurrency test.

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
