---
name: test-performance-budget
description: Optimize Rails test-suite performance using measured boot, database, factory, parallelization, and system-test costs.
family: testing
---

# Test Performance Budget

## Problem
Test suites grow until feedback becomes too slow to sustain development.

## Use when
A test suite or specific test group has a measured runtime problem.

## Procedure
1. Establish total and component-level baseline.
2. Identify slow files/tests and boot/setup overhead.
3. Measure factory/fixture, DB, system-test, and parallel overhead.
4. Make the smallest targeted improvement.
5. Re-run the same workload.
6. Confirm assertions and isolation remain intact.

## Failure modes
- removing assertions to gain speed
- global parallelization without measuring overhead
- eager-loading every helper
- replacing real contract tests with mocks solely for speed

## Testing
Compare before/after runtime using the same environment/workload.

## Review checklist
- baseline exists
- bottleneck identified
- change targeted
- coverage preserved
