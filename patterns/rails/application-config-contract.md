---
name: application-config-contract
description: Application Config Contract
family: rails
---
# Application Config Contract

## Problem
Application-owned settings need stable names, types, defaults, and access semantics.

## Use when
Adding config.x or another application namespace.

## Do not use when
Framework-owned behavior with an established Rails API.

## Repository inspection
Inspect existing config.x usage and consumers.

## Implementation procedure
Define one namespace and normalize values at the boundary.

## Failure modes
Stringly-typed drift and duplicated parsing.

## Testing
Test default, configured, malformed, and missing states.

## Review checklist
[ ] namespace [ ] type [ ] default [ ] consumer contract

## Related skills
rails-initialization-configuration-engineering, ruby-clean-code
