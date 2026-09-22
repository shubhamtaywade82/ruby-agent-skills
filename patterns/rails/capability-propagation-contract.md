---
name: capability-propagation-contract
description: Authorization Capability Propagation Contract
family: security
---
# Authorization Capability Propagation Contract

## Problem
Ambient current-user state does not compose safely across asynchronous or nested boundaries.

## Use when
A downstream operation requires proof that an upstream authorization decision was made.

## Do not use when
A fresh authorization decision is simpler and available at the boundary.

## Repository inspection
Inspect caller/callee relationships, capability shape, expiry, audience, and serialization needs.

## Implementation procedure
Pass a narrow, non-forgeable or explicitly scoped capability object/context with clear lifetime and audience.

## Failure modes
Overbroad bearer capability, serialized credentials, confused audience, indefinite lifetime.

## Testing
Test capability misuse, wrong resource/action, expiry, and caller substitution.

## Review checklist
[ ] narrow scope [ ] audience [ ] lifetime [ ] non-forgeable semantics

## Related skills
rails-cross-boundary-authorization-security, rails-dependency-injection