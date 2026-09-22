---
name: signed-globalid-integrity-contract
description: Signed Global ID Integrity Contract
family: rails
---
# Signed Global ID Integrity Contract

## Problem
Opaque identifiers passed through clients can be tampered with when integrity is not protected.

## Use when
A Global ID is exposed where clients can modify the referenced identity.

## Do not use when
The identifier is internal and integrity is already enforced by another trusted channel.

## Repository inspection
Inspect verifier/key ownership, expiry, purpose, transport, and authorization checks.

## Implementation procedure
Use Signed Global ID with explicit verifier, purpose, and lifetime; authorize the resolved object separately.

## Failure modes
Forged identifiers, wrong-purpose reuse, indefinite exposure, confused deputy behavior.

## Testing
Test tampering, wrong purpose, expiry, and successful validation.

## Review checklist
[ ] signature [ ] purpose [ ] expiry [ ] authorization

## Related skills
rails-serialization-globalid-engineering, rails-security-engineering, rails-authorization