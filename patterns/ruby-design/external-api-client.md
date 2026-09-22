---
name: external-api-client
description: Use when integrating a remote HTTP/API boundary that should be isolated from domain code and made testable.
family: ruby-design
---

# External API Client

## Problem

Remote APIs introduce transport, authentication, serialization, timeout, retry, and response-contract concerns that should not leak through the rest of the application.

## Use when

- a feature consumes a remote HTTP API
- raw HTTP calls appear in controllers/models
- an API response needs normalization before domain use
- external failure behavior must be tested independently

## Do not use when

- the repository already has a stable client for the same service
- the operation is a one-off script with no reusable boundary
- introducing a wrapper would only rename one existing method

## Repository inspection

Inspect existing HTTP libraries, client classes, authentication configuration, timeout conventions, error types, test doubles, and observability before creating a new boundary.

## Implementation procedure

1. define the domain-facing client API
2. isolate transport behind the client
3. centralize base URL/authentication/headers
4. set explicit connect/read timeouts where the library supports them
5. validate status and response shape
6. normalize external data into an application-facing structure
7. map remote failures to explicit local errors/results
8. make the transport replaceable in tests
9. avoid logging secrets or full sensitive payloads

## Failure modes

- raw HTTP calls scattered through business code
- no timeout
- accepting a successful HTTP status without validating the body
- leaking provider-specific response objects everywhere
- broad rescue that hides network failures
- retries without an idempotency/retry policy
- credentials embedded in source

## Testing

Test successful response mapping, non-success responses, malformed payloads, timeout behavior where practical, and the domain-facing contract. Use a fake transport rather than a real network call for unit tests.

## Review checklist

- [ ] client API is small and domain-oriented
- [ ] transport is isolated
- [ ] timeout/error behavior is explicit
- [ ] response validation exists
- [ ] secrets are not logged
- [ ] network calls are replaceable in tests
- [ ] provider-specific details do not leak unnecessarily

## Related skills

- ruby-gems-io-services
- ruby-api-design
- ruby-debugging
- ruby-tdd-refactoring
