---
name: engine-namespace-isolation
description: Engine Namespace Isolation
family: rails
---
# Engine Namespace Isolation

## Problem
Engine classes, routes, helpers, and tables can collide with host or other engines when isolation is absent or inconsistent.

## Use when
An engine intends to own namespaced components.

## Do not use when
The engine intentionally shares host namespaces under a documented contract.

## Repository inspection
Inspect isolate_namespace, constant paths, route helpers, model naming, and helper exposure.

## Implementation procedure
Use namespace isolation where ownership requires it and verify file, constant, route, and table contracts.

## Failure modes
Constant collisions, helper leakage, route collisions, and misleading model/table names.

## Testing
Test namespaced constants, helpers, routes, and representative models.

## Review checklist
[ ] isolation intent [ ] constant paths [ ] route helpers [ ] model/table contract

## Related skills
rails-engines-railties-engineering, rails-zeitwerk, rails-routing