---
name: environment-configuration-contract
description: Environment Configuration Contract
family: rails
---
# Environment Configuration Contract

## Problem
Intentional environment differences can become accidental divergence.

## Use when
Changing config/environments or environment-dependent behavior.

## Do not use when
A setting is identical everywhere.

## Repository inspection
Inspect environment files, application defaults, deployment config, and tests.

## Implementation procedure
Document why the difference exists and verify affected environments.

## Failure modes
Production-only failures and leaked development settings.

## Testing
Run environment-appropriate tests/boot checks.

## Review checklist
[ ] difference justified [ ] environments tested [ ] production path

## Related skills
rails-initialization-configuration-engineering, rails-production-runtime
