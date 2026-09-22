---
name: boot-performance-contract
description: Boot Performance Contract
family: rails
---
# Boot Performance Contract

## Problem
Slow initialization increases deployment and restart time.

## Use when
An initializer adds measurable startup work.

## Do not use when
Micro-optimization without evidence.

## Repository inspection
Inspect boot timings, eager loading, dependency calls, and restart frequency.

## Implementation procedure
Measure the slow boundary, remove unnecessary work, and defer optional work when valid.

## Failure modes
Premature optimization and semantic shortcuts.

## Testing
Use boot timing evidence and regression checks.

## Review checklist
[ ] baseline [ ] cost localized [ ] semantics preserved

## Related skills
rails-initialization-configuration-engineering, rails-production-runtime, rails-performance
