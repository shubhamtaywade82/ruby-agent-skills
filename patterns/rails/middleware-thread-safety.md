---
name: middleware-thread-safety
description: Keep middleware safe under concurrent request execution.
family: rails
---
# Middleware Thread Safety

## Problem
Shared mutable middleware state can race across threads, fibers, or processes.

## Use when
Middleware stores counters, caches, configuration, or reusable collaborators across requests.

## Do not use when
All state is immutable configuration or request-local state.

## Repository inspection
Inspect server concurrency, middleware object lifetime, shared variables, synchronization, and process topology.

## Implementation procedure
Move request state into local variables, make shared state immutable or explicitly synchronized, and choose process-safe stores for distributed limits.

## Failure modes
Race conditions, cross-request leakage, deadlocks, process-local inconsistency, and stale state.

## Testing
Use concurrent request tests where shared state exists and run relevant thread-safety checks.

## Review checklist
[ ] no request state in globals
[ ] synchronization justified
[ ] process model considered
[ ] concurrent test

## Related skills
rails-rack-middleware-engineering, ruby-concurrency, rails-performance
