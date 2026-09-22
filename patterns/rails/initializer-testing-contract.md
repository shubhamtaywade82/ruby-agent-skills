---
name: initializer-testing-contract
description: Initializer Testing Contract
family: rails
---
# Initializer Testing Contract

## Problem
Static inspection cannot prove boot-time registration or lifecycle behavior.

## Use when
A change affects initialization/configuration.

## Do not use when
Pure application code with no initialization effect.

## Repository inspection
Inspect existing boot/config test conventions.

## Implementation procedure
Test the lifecycle boundary and add clean boot coverage for deployment-critical behavior.

## Failure modes
Hidden environment state and tests that never execute the initializer.

## Testing
Run isolated tests and clean-process boot verification where practical.

## Review checklist
[ ] lifecycle executed [ ] env assumptions explicit [ ] boot regression

## Related skills
rails-initialization-configuration-engineering, rails-test-engineering
