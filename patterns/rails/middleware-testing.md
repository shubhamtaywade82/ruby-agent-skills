---
name: middleware-testing
description: Test middleware behavior at the Rack boundary and stack integration boundary.
family: rails
---
# Middleware Testing

## Problem
Controller-only tests can miss ordering, short-circuit, body, exception, and environment contracts.

## Use when
Adding or changing custom middleware or middleware registration.

## Do not use when
A change has no middleware behavior and existing higher-level tests already cover the relevant contract.

## Repository inspection
Inspect existing Rack/request/system test conventions and available Rails middleware test helpers.

## Implementation procedure
Write focused Rack tests for the component, integration tests for registration/order, and system tests only for user-visible browser behavior.

## Failure modes
Tests that pass while middleware is absent, misordered, or leaking state.

## Testing
Cover delegation, early exit, headers/status, exceptions, body lifecycle, and concurrency/security cases as applicable.

## Review checklist
[ ] direct boundary test
[ ] registration/order test
[ ] failure path
[ ] no redundant browser test

## Related skills
rails-rack-middleware-engineering, rails-test-engineering
