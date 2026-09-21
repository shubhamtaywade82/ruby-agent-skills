---
name: request-contract
description: Test an HTTP endpoint from routing through response while keeping assertions on the stable external contract.
family: testing
---

# Request Contract

## Problem
Controller implementation tests can miss routing, middleware, authentication, serialization, and persistence integration.

## Use when
The behavior is an HTTP/API contract.

## Implementation procedure
1. Issue a real request through the application routing boundary.
2. Set only required authentication/headers/params.
3. Assert status and response schema/body.
4. Assert important persistence or side effects.
5. Cover expected client failures.
6. Keep internal collaborator details out of the request test.

## Failure modes
- calling controller methods directly for an HTTP contract
- asserting only status
- coupling to private methods
- omitting authentication/authorization behavior

## Testing
Use focused request tests plus lower-level tests for domain rules.

## Review checklist
- route exercised
- external contract asserted
- key side effect asserted
- authorization behavior included


## Repository inspection

Inspect runtime/version, repository conventions, the owning boundary, neighboring implementations, and applicable tests before applying the pattern.


## Related skills

- rails-testing
- ruby-tdd-refactoring
- rails-architecture
