---
name: engine-configuration-boundary
description: Engine Configuration Boundary
family: rails
---
# Engine Configuration Boundary

## Problem
Engine behavior becomes fragile when it reads arbitrary host globals instead of an explicit configuration API.

## Use when
Adding or changing engine settings or host-provided policy.

## Do not use when
The value is purely internal implementation state.

## Repository inspection
Inspect engine config APIs, defaults, host overrides, environment variables, credentials, and consumers.

## Implementation procedure
Define namespaced configuration with explicit defaults, override timing, and validation.

## Failure modes
Stringly-typed drift, hidden host coupling, boot-order dependence.

## Testing
Test defaults, host overrides, invalid configuration, and boot timing.

## Review checklist
[ ] public config [ ] defaults [ ] override semantics [ ] validation

## Related skills
rails-engines-railties-engineering, rails-initialization-configuration-engineering