---
name: action-controller-request-boundary
description: Use when a controller must translate HTTP request data into an explicit application input contract.
family: rails
---

# Action Controller Request Boundary

## Problem

Controllers often accept mixed query, path, body, header, cookie, and session data without an explicit boundary. That makes transport concerns leak into domain code and complicates security review.

## Use when

- an action receives multiple parameter sources
- request metadata affects behavior
- input normalization or rejection must be explicit
- a controller calls a service or domain operation.

## Do not use when

- the task is only route declaration
- a dedicated request object already owns the boundary and the controller does not change it
- business validation is being redesigned.

## Repository inspection

Inspect the route, controller inheritance, authentication, parameter conventions, request tests, and application service API.

## Implementation procedure

1. Identify each request input source.
2. Separate HTTP-only metadata from business inputs.
3. Filter and normalize at the controller edge.
4. Convert the accepted shape into the smallest application input.
5. Call the owning domain/service object.
6. Map the result back to HTTP without forwarding raw params.
7. Add negative tests for malformed and unexpected input.

## Failure modes

- forwarding raw params
- treating headers as trusted business fields
- mixing authorization into normalization
- duplicating domain validation in the controller.

## Testing

Test accepted shape, rejected shape, nested input, and security-sensitive request variants.

## Review checklist

- [ ] input sources are identified
- [ ] permitted shape is explicit
- [ ] domain code never receives raw request state
- [ ] authorization remains separate
- [ ] negative cases are tested

## Related skills

rails-action-controller, rails-controllers, rails-authentication, rails-security, rails-testing
