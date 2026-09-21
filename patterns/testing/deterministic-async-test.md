---
name: deterministic-async-test
description: Test asynchronous Rails jobs without sleeps, timing races, or bypassing the relevant framework boundary.
family: testing
---

# Deterministic Async Test

## Problem
Asynchronous code is commonly tested with sleeps or direct method calls that bypass serialization and queue behavior.

## Use when
Testing Active Job, delayed side effects, polling, or asynchronous workflow boundaries.

## Procedure
1. Identify enqueue versus execution contract.
2. Assert enqueue with ActiveJob::TestHelper when applicable.
3. Use perform_enqueued_jobs for controlled execution.
4. Control time explicitly.
5. Replace sleeps with condition-driven/test-helper synchronization.
6. Test retry/failure behavior at the intended boundary.

## Failure modes
- Thread.sleep/sleep-based assertions
- direct perform as the only job test
- real queue worker in ordinary unit tests
- test passes because the race was hidden

## Testing
Cover both enqueue and execution when both are part of the contract.

## Review checklist
- queue boundary tested
- serialization not accidentally bypassed
- no sleep-based synchronization
- deterministic execution
