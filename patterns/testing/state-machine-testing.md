---
name: state-machine-testing
description: Test a durable state machine as a complete matrix — allowed, rejected, concurrent, duplicate, out-of-order, and recovery paths.
family: testing
---

# State Machine Testing

## Problem

State machines are tested through the happy path, so the failures that matter in production — double transitions, out-of-order events, crashes between side effect and persistence — are never exercised until they corrupt real records.

## Use when

A durable model has transition semantics and the test suite must prove the contract: what is allowed, what is rejected, and what happens when things race or arrive twice.

## Do not use when

The state column has no transition semantics (plain attribute tests suffice) or the state machine lives in another service and only its published events are observable (contract-test the event stream instead).

## Repository inspection

Inspect the transition table, the entry point and its locking, every event source and its delivery semantics, side effects and their sequencing, and the audit trail. Derive the real table from writers before testing the documented one.

## Implementation procedure

1. Enumerate states and events; build the classification matrix (legal, illegal, unknown) from the table.
2. Test one allowed transition per edge, asserting state, audit row, and side effects together.
3. Test one rejection per illegal edge, asserting the failure is loud (exception class or explicit result) and state is unchanged.
4. Test terminal states: no events apply; state remains final.
5. Test concurrency: two simultaneous `apply_event!` on the same record — exactly one succeeds.
6. Test duplicate event application: same event identity twice — same final state, effects once.
7. Test out-of-order delivery (for event-driven machines): late events rejected, buffered, or reconciled per policy.
8. Test recovery: simulate crash between intent and side effect; assert the recovery path completes or reconciles.
9. Assert audit completeness for every applied transition.

## Example

```ruby
class OrderStateMachineTest < ActiveSupport::TestCase
  test "concurrent fill attempts succeed exactly once" do
    order = orders(:pending)
    barrier = Queue.new
    results = 2.times.map do
      Thread.new do
        barrier.pop
        order.reload.apply_event!("fill", actor: users(:trader))
        :ok
      rescue Order::IllegalTransition
        :rejected
      end
    end
    2.times { barrier << :go }
    outcomes = results.map(&:value)

    assert_equal %i[ok rejected].sort, outcomes.sort
    assert_equal "filled", order.reload.state
    assert_equal 1, order.state_audits.where(event: "fill").count
  end
end
```

## Failure modes

- Testing only the happy path through one edge.
- Rejection tests that assert nothing was raised (silently swallowing the failure mode).
- Concurrency tests that serialize by accident (setup in the thread body, missing barrier).
- Duplicate tests that rely on memory ("we would never call it twice") instead of durable identity.
- Recovery tests that never simulate the actual crash window (kill between commit and side effect).
- Matrix tests that stop when the table gets large — generate from the table instead.

## Testing

The pattern is the test plan: keep the matrix generated from the table so a new state or event fails loudly in the test suite, not in production data.

## Review checklist

- [ ] matrix generated from the table, every pair classified
- [ ] illegal edges fail loudly with state unchanged
- [ ] concurrency race reproduced deterministically (barrier, not sleep)
- [ ] duplicate application idempotent with durable identity
- [ ] out-of-order delivery policy tested
- [ ] recovery path tested through the real crash window
- [ ] audit rows asserted alongside state

## Related skills

rails-state-machine-engineering, rails-test-engineering, ruby-tdd-refactoring
