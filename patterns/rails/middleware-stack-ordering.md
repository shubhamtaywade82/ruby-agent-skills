---
name: middleware-stack-ordering
description: Make middleware ordering an explicit behavioral contract.
family: rails
---
# Middleware Stack Ordering

## Problem
Two individually valid middleware components can produce incorrect behavior when their relative order changes.

## Use when
Adding, removing, or reordering middleware.

## Do not use when
A component has no stack interaction or ordering dependency.

## Repository inspection
Inspect config.middleware, bin/rails middleware output, environment-specific configuration, and tests.

## Implementation procedure
Identify producer/consumer and failure/security dependencies, then place middleware at the narrowest correct boundary and test the order.

## Failure modes
Headers missing, exceptions bypassed, security checks skipped, or observability initialized too late.

## Testing
Assert stack order where order is contractual and exercise the affected request path.

## Review checklist
[ ] order justified
[ ] environment differences inspected
[ ] order regression covered
[ ] no cosmetic reorder

## Related skills
rails-rack-middleware-engineering, rails-production-runtime, rails-security-engineering
