---
name: engine-cross-engine-composition
description: Engine Cross-Composition Contract
family: rails
---
# Engine Cross-Composition Contract

## Problem
Multiple engines can accidentally depend on load order, shared globals, or private implementation details.

## Use when
Adding or changing dependencies between engines.

## Do not use when
A single engine has no other engine dependency.

## Repository inspection
Inspect dependency graph, namespaces, initializers, routes, configuration, and shared contracts.

## Implementation procedure
Expose stable interfaces, avoid private constant coupling, and make required initialization order explicit.

## Failure modes
Circular dependencies, load-order bugs, namespace collisions, cascading upgrades.

## Testing
Test participating engines in host composition and verify boot/load order.

## Review checklist
[ ] dependency graph [ ] public interface [ ] no private coupling [ ] composition test

## Related skills
rails-engines-railties-engineering, rails-initialization-configuration-engineering, rails-zeitwerk