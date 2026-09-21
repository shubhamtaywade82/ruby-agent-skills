---
name: flaky-test-diagnosis
description: Diagnose nondeterministic test failures by reproducing the exact execution conditions.
family: testing
---

# Flaky Test Diagnosis

## Problem
A test that sometimes passes and sometimes fails provides weak evidence and can hide real regressions.

## Use when
A test fails intermittently or only under CI/parallel execution.

## Procedure
1. Capture test name and random seed.
2. Capture Ruby/Rails/runtime and CI configuration.
3. Reproduce with identical parallelism/order.
4. Classify the failure: timing, state leak, order, transaction, external dependency, time zone, randomness, or environment.
5. Fix the source of nondeterminism.
6. Run repeated verification.
7. Keep a regression test for the discovered defect.

## Failure modes
- adding retries as the fix
- increasing sleeps
- disabling parallel tests globally
- changing test order until the failure disappears

## Testing
Use repeated runs only as evidence of reproducibility; the fix must remove the underlying nondeterminism.

## Review checklist
- original conditions captured
- root cause classified
- actual isolation/timing issue fixed
- repeated verification performed
