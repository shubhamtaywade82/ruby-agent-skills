---
name: credentials-redaction-contract
description: Secret Redaction and Filtering Contract
family: rails
---
# Secret Redaction and Filtering Contract

## Problem
Secrets can leak through logs, SQL, job payloads, traces, object inspection, or support tooling even when stored securely.

## Use when
Adding sensitive credentials or encrypted attributes.

## Do not use when
The value is demonstrably non-sensitive.

## Repository inspection
Inspect filter_parameters, SQL logging, structured logging, tracing, exception reporting, job arguments, and model inspect output.

## Implementation procedure
Configure redaction at each applicable observability boundary and test that representative values are filtered.

## Failure modes
Secret leakage through a secondary channel such as logs or traces.

## Testing
Assert logs/exceptions/job inspection do not contain representative secret values.

## Review checklist
[ ] parameters filtered [ ] attributes filtered [ ] tracing reviewed [ ] jobs reviewed

## Related skills
rails-encryption-credentials-engineering, rails-observability, rails-security-engineering