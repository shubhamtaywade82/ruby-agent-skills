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
