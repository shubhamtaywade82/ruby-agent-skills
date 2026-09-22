---
name: operational-observability-contract
description: Operational Observability Contract
family: rails
---
# Operational Observability Contract

## Problem
Operators cannot safely verify progress or outcome when maintenance tasks emit insufficient or unsafe diagnostics.

## Use when
Tasks with significant duration, blast radius, or recovery implications.

## Do not use when
Tiny local-only tasks where ordinary command output is sufficient.

## Repository inspection
Inspect logging conventions, metrics/instrumentation, runbooks, and sensitive-field rules.

## Implementation procedure
Report bounded counts, progress, failures, duration, and final state without secret or high-cardinality payloads.

## Failure modes
No evidence of progress, misleading success, secret leakage, or unusably noisy logs.

## Testing
Test output for expected milestones and absence of sensitive values.

## Review checklist
[ ] progress [ ] final summary [ ] exit semantics [ ] secret-safe

## Related skills
rails-operational-tasks-maintenance, rails-observability