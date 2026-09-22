---
name: engine-boundary-contract
description: Engine Boundary Contract
family: rails
---
# Engine Boundary Contract

## Problem
Host ownership and engine ownership become unclear when an extension boundary is implicit.

## Use when
Introducing or modifying a Rails Engine.

## Do not use when
Ordinary application modules without an Engine boundary.

## Repository inspection
Inspect engine class, gemspec, namespace, host integration, and lifecycle hooks.

## Implementation procedure
Define engine-owned behavior, host-owned behavior, integration points, and compatibility boundaries.

## Failure modes
Hidden host coupling, lifecycle leakage, and unreviewable extension behavior.

## Testing
Test engine boot plus one host integration path.

## Review checklist
[ ] ownership explicit [ ] integration points explicit [ ] compatibility reviewed

## Related skills
rails-engines-railties-engineering, rails-initialization-configuration-engineering