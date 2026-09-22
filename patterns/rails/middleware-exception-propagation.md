---
name: middleware-exception-propagation
description: Preserve intentional exception ownership across middleware.
family: rails
---
# Middleware Exception Propagation

## Problem
A broad middleware rescue can hide application failures or bypass Rails error handling and telemetry.

## Use when
Middleware must translate, classify, or instrument a known failure boundary.

## Do not use when
Generic error swallowing or replacing framework exception handling is proposed without a contract.

## Repository inspection
Inspect Rails exception handling, rescue_from usage, error reporting, environment behavior, and upstream expectations.

## Implementation procedure
Rescue only the owned exception classes, preserve cause/context, emit telemetry, and return a response only when the middleware contract requires it.

## Failure modes
Hidden programmer errors, duplicate error reporting, incorrect status codes, and false-success responses.

## Testing
Test handled exceptions, unhandled exceptions, telemetry expectations, and environment-specific responses.

## Review checklist
[ ] rescue scope narrow
[ ] owner documented
[ ] original failure preserved
[ ] failure test exists

## Related skills
rails-rack-middleware-engineering, rails-observability, rails-action-controller
