---
name: parallel-safe-test
description: Make tests independent of process/thread order, shared state, fixed resources, and implicit database transactions.
family: testing
---

# Parallel-Safe Test

## Problem
Parallel execution exposes hidden shared state and resource collisions.

## Use when
Enabling/tuning Rails parallel tests or fixing failures that appear only under parallel execution.

## Procedure
1. Reproduce with the reported worker count/seed.
2. Identify shared state/resource.
3. Isolate database/process/port/filesystem/cache state.
4. Remove order dependency.
5. Verify transaction semantics for concurrent database work.
6. Re-run in parallel and serial modes.

## Failure modes
- global variables/singletons leaking state
- fixed ports/temp paths
- shared external fake state
- test transaction blocking independent transactions
- reducing parallelism instead of fixing the race

## Testing
Run the focused case repeatedly under the parallel configuration and then the relevant suite.

## Review checklist
- failure reproduces under same seed/configuration
- shared state identified
- isolation fixed
- serial and parallel runs agree
