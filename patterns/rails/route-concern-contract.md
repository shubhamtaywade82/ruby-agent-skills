---
name: route-concern-contract
description: Use when extracting or reusing a stable group of Rails resource routes through routing concerns.
family: rails
---

# Route Concern Contract

## Problem

Routing concerns reduce duplication but can silently expand unrelated resources, change helper names, or create surprising nested routes.

## Use when

- multiple resources expose the same route capability;
- a route group has a stable semantic name;
- duplicate route declarations are a maintenance risk.

## Do not use when

- the shared route set exists only once;
- resources do not truly share the same public route contract.

## Repository inspection

Inspect all concern callers, route expansions, helper names, nesting, and tests.

## Implementation procedure

1. Name the shared route capability.
2. Verify each caller needs the same contract.
3. Extract the smallest reusable concern.
4. Inspect bin/rails routes after expansion.
5. Add representative recognition/generation tests.

## Failure modes

- broad concern applied to incompatible resources;
- helper collisions;
- nested route expansion surprises;
- concern becomes a business-workflow abstraction.

## Testing

Test representative route expansions and helper uniqueness.

## Review checklist

- [ ] semantic capability is shared
- [ ] callers are compatible
- [ ] expansion inspected
- [ ] helper collisions ruled out

## Related skills

rails-routing, rails-testing
