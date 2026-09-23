---
name: typescript-runtime-schema-boundary
description: Validate unknown external data once before treating it as typed application data.
family: react-typescript
---

# Typescript Runtime Schema Boundary

## Problem
JSON, HTTP, storage, environment, or dynamic JavaScript crosses a trust boundary.

## Use when
The input is already produced by a trusted in-process contract with no runtime uncertainty.

## Do not use when
Do not activate simply when The input is already produced by a trusted in-process contract with no runtime uncertainty. 

## Repository inspection
Inspect where data enters, current schema utilities, and error handling.

## Implementation procedure
Parse unknown input, validate at the boundary, normalize if required, and pass trusted data inward.

## Failure modes
Type assertions as validation, repeated validation in every consumer, and unsafe logging of payloads.

## Testing
Test malformed, missing, extra, and version-drift input.

## Review checklist
Is runtime validation owned by one deliberate boundary?

## Related skills
typescript-runtime-contracts,typescript-core-engineering
