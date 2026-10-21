# Test Engineering Review

Use this reference when a change adds behavior, fixes a defect, refactors code, changes test infrastructure, or relies on tests as evidence. Compose with ruby-tdd-refactoring and rails-test-engineering and follow the repository's actual test framework and commands.

## Assertion quality

Tests should establish observable behavior and important invariants, not merely echo implementation logic or private call sequences. Prefer independently worked expected values where practical.

```ruby
# Weak: expectation repeats the implementation's calculation.
expect(order.total).to eq(order.items.sum(&:price))

# Stronger: independent example, assuming the contract sums price.
expect(order.total).to eq(30)
```

A test whose actual and expected values use the same faulty logic can pass while the feature is wrong.

## Behavior and test boundary

Choose the smallest test boundary that proves the contract:

- Pure/domain invariant → unit or model test.
- Workflow across owned objects → focused service/domain/integration test.
- HTTP status, response, persistence, or authorization contract → request/integration test.
- Browser-visible workflow → system/E2E test when repository conventions support it.
- Background job execution → job test; enqueue behavior belongs at the caller boundary.
- Provider behavior → isolate the external boundary and separately test the application contract.

More than one level is appropriate when they prove different contracts. Do not duplicate the same assertion at every layer merely to increase count.

## Negative and regression cases

Look for coverage of normal behavior, invalid input, nil/empty/boundary values, authorization denial, error paths, side effects, state transitions, and retry/duplicate behavior where relevant. For bug fixes, prefer a test that demonstrates the original failure before the fix, then passes afterward.

## Mocks, fixtures, and determinism

Prefer real owned code; use fakes/stubs/mocks where external side effects, nondeterminism, latency, or unavailable services justify them. Excessive mocking can make tests pass while production behavior is broken. Inspect existing factories, fixtures, and helpers before adding infrastructure.

Investigate unnecessary sleeps, external network dependencies, order dependence, shared mutable state, uncontrolled time/randomness, test database leakage, and parallel-safety issues. Test names should state behavior, and assertions should not merely enforce incidental implementation details.

## Verification evidence

Run the repository's documented focused test and broader relevant suite when practical. Record exact commands and observed results. Do not claim tests passed because they exist or because an agent predicts success. A passing suite does not prove untested behavior correct; a skipped or unrun test is not a pass.
