---
name: graceful-shutdown
description: Make Rails web and job processes stop safely within the platform termination budget.
family: rails
---

# Graceful Shutdown

## Problem
Abrupt process termination can drop requests, interrupt jobs, or leak resources.

## Use when
Changing TERM/QUIT handling, container shutdown, process-manager configuration, worker lifecycle, or restart behavior.

## Implementation procedure
1. Identify termination signal sequence.
2. Identify the hard kill deadline.
3. Stop accepting new work.
4. Allow safe in-flight work to finish.
5. Release resources.
6. Exit before the hard deadline.
7. Test graceful termination and forced termination recovery.

## Failure modes
- shutdown timeout exceeds orchestrator kill timeout
- PID 1 swallows signals
- job workers exit before safe handoff
- long-running work cannot be interrupted/replayed safely

## Review checklist
- signal flow understood
- deadline compatible
- in-flight work semantics understood
- resources released
- recovery path exists


## Repository inspection

Inspect runtime/version, repository conventions, the owning boundary, neighboring implementations, and applicable tests before applying the pattern.


## Related skills

- rails-testing
- ruby-tdd-refactoring
- rails-architecture
