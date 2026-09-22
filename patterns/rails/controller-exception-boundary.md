---
name: controller-exception-boundary
description: Use when controller exceptions must be mapped to stable HTTP responses without hiding programmer defects.
family: rails
---

# Controller Exception Boundary

## Problem

Controllers need predictable responses for expected domain failures, but broad rescue logic can hide defects and destroy observability.

## Use when

- adding rescue_from
- mapping domain errors to status codes
- standardizing controller error representations
- reviewing exception handling.

## Do not use when

- a central application error boundary already owns the behavior
- the exception has no stable HTTP meaning.

## Repository inspection

Inspect global error handling, ApplicationController, observability/error reporting, API error schema, and request tests.

## Implementation procedure

1. List expected exception classes.
2. Map each to an intentional HTTP status and representation.
3. Keep programmer defects unhandled by local rescue logic.
4. Preserve correlation/error context for observability.
5. Test expected exceptions and unexpected exceptions separately.

## Failure modes

- rescuing StandardError broadly
- converting authorization failures into successful responses
- exposing exception messages or stack traces in production
- double-reporting a globally handled exception.

## Testing

Assert status, body/content type, security-sensitive redaction, and observability behavior where practical.

## Review checklist

- [ ] exception classes are intentional
- [ ] mappings are stable
- [ ] unexpected errors still fail correctly
- [ ] sensitive details are not exposed
- [ ] error reporting is not duplicated

## Related skills

rails-action-controller, rails-observability, rails-security, rails-api-integration
