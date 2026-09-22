---
name: rack-request-response-contract
description: Preserve the Rack environment and response tuple contract at a middleware boundary.
family: rails
---
# Rack Request Response Contract

## Problem
A middleware can accidentally return an invalid response or corrupt the downstream environment/body lifecycle.

## Use when
Implementing or reviewing a Rack middleware boundary.

## Do not use when
Changing ordinary controller behavior without a Rack boundary.

## Repository inspection
Inspect Rack/Rails versions, existing middleware, env keys, response wrappers, and Rack request tests.

## Implementation procedure
Keep env mutation explicit, delegate exactly once when required, return a valid status/headers/body tuple, and preserve body ownership.

## Failure modes
Invalid response shape, accidental double delegation, body leaks, and incompatible env mutations.

## Testing
Exercise normal delegation, short-circuit responses, headers, status, and body closure where applicable.

## Review checklist
[ ] response contract explicit
[ ] env mutations bounded
[ ] body ownership verified
[ ] delegation semantics tested

## Related skills
rails-rack-middleware-engineering, rails-testing
