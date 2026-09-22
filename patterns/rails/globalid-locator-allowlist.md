---
name: globalid-locator-allowlist
description: Global ID Locator Allowlist Contract
family: rails
---
# Global ID Locator Allowlist Contract

## Problem
Arbitrary model resolution can widen the set of classes an untrusted identifier may reference.

## Use when
Resolving Global IDs from external or cross-service input.

## Do not use when
A tightly controlled internal locator with an enforced class boundary.

## Repository inspection
Inspect GlobalID app name, model names, locator configuration, class restrictions, and custom locators.

## Implementation procedure
Restrict locatable classes and applications where possible and make custom locator behavior explicit.

## Failure modes
Unexpected model resolution, class confusion, unsafe cross-application references.

## Testing
Test permitted/rejected model classes and malformed or foreign IDs.

## Review checklist
[ ] class allowlist [ ] app boundary [ ] malformed input [ ] custom locator

## Related skills
rails-serialization-globalid-engineering, rails-security-engineering