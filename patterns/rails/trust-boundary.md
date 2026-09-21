---
name: trust-boundary
description: Place validation, authentication, authorization, and encoding controls at the boundary where trust or authority changes.
family: rails
---

# Trust Boundary

## Problem

Untrusted or lower-authority data crosses into a higher-trust component without a clear security owner.

## Use when

Browsers, tenants, providers, services, brokers, files, URLs, or build systems exchange security-sensitive data.

## Do not use when

No trust or authority boundary changes.

## Repository inspection

Inspect caller identity, data provenance, validation, authorization, normalization, serialization, logging, and downstream sinks.

## Implementation procedure

1. Identify source trust level.
2. Identify destination authority.
3. List allowed inputs/capabilities.
4. Authenticate where identity is required.
5. Authorize the requested action/resource.
6. Validate and normalize data at the boundary.
7. Encode/output according to the destination context.
8. Test invalid, forged, and unauthorized inputs.

## Failure modes

- downstream code assumes upstream validation
- authorization only in UI/controller
- provider payload trusted because signature checks were incomplete
- validation performed after a dangerous sink

## Testing

Test forged identity, unauthorized action, invalid input, boundary normalization, and dangerous sink protection.

## Review checklist

- [ ] trust levels explicit
- [ ] control owner explicit
- [ ] authentication/authorization separated
- [ ] validation before sink
- [ ] abuse path tested

## Related skills

- rails-security-engineering
- rails-security
- rails-api-integration
