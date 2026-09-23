---
name: typescript-async-error-normalization
description: Normalize asynchronous failures into a small typed contract at the integration boundary.
family: react-typescript
---

# Typescript Async Error Normalization

## Problem
Multiple async providers expose different failure shapes.

## Use when
A provider already exposes the exact domain error contract and no translation is needed.

## Do not use when
Do not activate simply when A provider already exposes the exact domain error contract and no translation is needed. 

## Repository inspection
Inspect promise rejection, network client errors, cancellation, and caller expectations.

## Implementation procedure
Map transport/provider failures to deliberate domain categories while preserving cancellation semantics.

## Failure modes
Catching everything as one generic error, retrying non-retryable errors, or losing cancellation identity.

## Testing
Test timeout, cancellation, provider error, malformed response, and success paths.

## Review checklist
Can callers distinguish retryable, terminal, and cancelled work?

## Related skills
typescript-runtime-contracts,typescript-core-engineering
