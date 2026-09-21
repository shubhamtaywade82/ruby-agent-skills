---
name: puma-capacity
description: Size Puma workers and threads against CPU, memory, database pool, and downstream capacity.
family: rails
---

# Puma Capacity

## Problem
Puma concurrency settings create aggregate CPU, memory, database, and dependency load.

## Use when
Changing workers, threads, WEB_CONCURRENCY, RAILS_MAX_THREADS, or production request capacity.

## Implementation procedure
1. Inspect CPU and memory limits.
2. Determine current workers and threads.
3. Determine database pool and downstream limits.
4. Estimate aggregate concurrency.
5. Change one capacity dimension.
6. Measure request latency, queueing, memory, CPU, and DB pool pressure.
7. Retune using evidence.

## Failure modes
- threads exceed database capacity
- workers exceed memory budget
- optimizing CPU while requests are DB-bound
- using generic worker counts without workload evidence

## Testing
Run production-like load/capacity checks where available.

## Review checklist
- CPU budget known
- memory budget known
- DB budget known
- downstream limits considered
- change is measured


## Repository inspection

Inspect runtime/version, repository conventions, the owning boundary, neighboring implementations, and applicable tests before applying the pattern.


## Related skills

- rails-testing
- ruby-tdd-refactoring
- rails-architecture
