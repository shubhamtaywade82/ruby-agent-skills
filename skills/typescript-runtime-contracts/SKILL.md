---
name: typescript-runtime-contracts
description: Use when untrusted JSON, HTTP responses, environment values, browser storage, or dynamic JavaScript enters typed TypeScript code.
---

# TypeScript Runtime Contracts

## Purpose
Keep compile-time declarations and runtime truth separate. Validate untrusted data at the boundary before application code treats it as trusted.

## Activate when
- consuming HTTP or JSON responses;
- parsing environment variables or storage;
- processing dynamic JavaScript values;
- adding schemas or serialization contracts.

## Repository inspection
Inspect transport clients, existing validation libraries, generated types, error normalization, retry behavior, and current validation boundaries.

## Decision rules
- unknown is the default type for untrusted values.
- Validate once at a deliberate boundary, then pass narrowed domain data inward.
- Keep validation failures distinct from transport failures.
- Avoid duplicating the same schema in every consumer.
- Keep schema/version ownership explicit.
- Redact sensitive values before logging malformed payloads.

## Implementation procedure
1. Locate the trust boundary.
2. Define the accepted runtime shape.
3. Parse and validate.
4. Normalize transport representation where appropriate.
5. Test malformed, missing, extra, and version-drift input.
6. Keep validation failures safe and actionable.

## Anti-patterns / failure modes
- asserting a response is correct without validation;
- trusting generated types as proof of runtime data;
- validation scattered across unrelated UI components;
- logging full invalid responses containing secrets.

## Verification
Exercise malformed payloads and schema drift as well as successful input. Verify caller behavior after validation failures.

## Source foundation
- TypeScript Handbook: https://www.typescriptlang.org/docs/handbook/intro.html
- Fetch API: https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API
