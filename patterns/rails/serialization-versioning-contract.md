---
name: serialization-versioning-contract
description: Serialization Versioning Contract
family: rails
---
# Serialization Versioning Contract

## Problem
Changing a serialized field's meaning or removing it can break consumers independently of application deploys.

## Use when
Changing externally consumed payload shape or semantics.

## Do not use when
Purely internal hashes with no persisted or external consumers.

## Repository inspection
Inventory API clients, jobs, stored payloads, fixtures, caches, and integrations.

## Implementation procedure
Classify additive versus breaking changes; use compatibility windows or explicit versions and deprecation rules.

## Failure modes
Silent semantic drift, old consumers failing, replay incompatibility.

## Testing
Test supported old and new fixtures and representative consumers.

## Review checklist
[ ] consumers [ ] compatibility window [ ] versions [ ] deprecation

## Related skills
rails-serialization-globalid-engineering, rails-api-integration, rails-release-engineering