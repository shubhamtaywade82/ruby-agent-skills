---
name: initializer-dependency-contract
description: Initializer Dependency Contract
family: rails
---
# Initializer Dependency Contract

## Problem
Initializer order becomes fragile when dependencies rely on incidental filename order.

## Use when
An initializer depends on another registration.

## Do not use when
Independent configuration.

## Repository inspection
Inspect initializer order, hooks, framework phases, and consumers.

## Implementation procedure
Move shared setup to the correct lifecycle phase and make dependencies explicit.

## Failure modes
Boot races, nil constants, duplicate setup.

## Testing
Run boot/initializer tests.

## Review checklist
[ ] dependency explicit [ ] phase correct [ ] no incidental order

## Related skills
rails-initialization-configuration-engineering, zeitwerk
