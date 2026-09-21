---
name: instrumentation-event
description: Define a stable ActiveSupport::Notifications event without coupling subscribers to domain side effects.
family: rails
---

# Instrumentation Event

## Problem
Application events need observable, reusable contracts for metrics, auditing, and diagnostics.

## Use when
A business/application boundary needs measurement or external observation.

## Implementation procedure
1. Choose a stable event.library name.
2. Define minimal payload fields.
3. Instrument the meaningful boundary.
4. Keep subscribers observational.
5. Define failure/duration semantics.
6. Test event name and required payload fields.

## Failure modes
- event name changes casually
- high-cardinality payload used as metric dimensions
- subscriber mutates business state
- instrumentation wraps too many tiny methods

## Testing
Subscribe during the test and assert the event contract.

## Review checklist
- stable event name
- minimal payload
- side-effect-free subscriber
- meaningful boundary

## Repository inspection

Inspect the repository's runtime/version, existing conventions, neighboring tests or implementation patterns, and the actual owning boundary before applying this pattern.

## Related skills

- rails-testing
- ruby-tdd-refactoring
- rails-architecture
## Do not use when

Do not use when no observable event, metric, audit, or diagnostic boundary is required.
