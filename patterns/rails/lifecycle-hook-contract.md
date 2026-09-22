---
name: lifecycle-hook-contract
description: Lifecycle Hook Contract
family: rails
---
# Lifecycle Hook Contract

## Problem
Boot, preparation, and runtime hooks have different execution semantics.

## Use when
Using before_initialize, after_initialize, to_prepare, or related hooks.

## Do not use when
Ordinary request/job behavior.

## Repository inspection
Inspect Rails version, reload mode, existing hooks, and reloadable code.

## Implementation procedure
Choose the narrowest correct lifecycle phase and execution frequency.

## Failure modes
Duplicate callbacks, stale classes, missed initialization.

## Testing
Test boot and reload-sensitive behavior.

## Review checklist
[ ] phase justified [ ] frequency understood [ ] reload tested

## Related skills
rails-initialization-configuration-engineering, zeitwerk
