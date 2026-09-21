---
name: turbo-form-contract
description: Preserve authentication, validation, HTTP status, redirect, and HTML fallback semantics for Turbo forms.
family: rails
---
# Turbo Form Contract

## Problem
Turbo changes browser behavior while server responses accidentally become ambiguous.

## Structure
Authorize and validate normally; return deliberate status, redirect, frame, or stream responses.

## Testing
Cover success, validation failure, unauthorized access, CSRF rejection, and non-JavaScript fallback where required.

## Do not use when
The operation is not a browser form interaction.

## Repository inspection
Inspect authentication, authorization, CSRF, validation, form builders, status codes, redirects, and Turbo response formats.

## Implementation procedure
Keep server-side authorization and validation authoritative, then choose render, redirect, or stream response.

## Failure modes
Success on invalid input, incorrect status, CSRF weakening, and inaccessible error rendering.

## Testing
Cover success, validation failure, unauthorized access, CSRF rejection, and fallback HTML.

## Review checklist
Security and HTTP semantics remain independent of Turbo behavior.

## Related skills
rails-hotwire, rails-authentication, rails-authorization, rails-security, rails-action-controller

## Use when

Use this pattern when the described Hotwire interaction is an explicit part of the page contract and its lifecycle needs dedicated guidance.
