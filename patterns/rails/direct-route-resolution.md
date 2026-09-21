---
name: direct-route-resolution
description: Use when introducing Rails direct routes or resolve mappings for custom URL generation and object routing.
family: rails
---

# Direct Route and Resolve Mapping

## Problem

Direct routes and resolve mappings can provide stable object-oriented URL generation, but opaque generation blocks can hide public behavior and complicate helper contracts.

## Use when

- conventional resource helpers do not express the desired URL-generation contract;
- singular/custom object routing needs explicit mapping.

## Do not use when

- conventional resource or polymorphic helpers already express the behavior clearly.

## Repository inspection

Inspect existing direct/resolve declarations, polymorphic helpers, to_param, model naming, and route-generation tests.

## Implementation procedure

1. State the caller-facing URL-generation contract.
2. Prefer conventional routing first.
3. Add direct/resolve only for a demonstrated gap.
4. Keep mappings deterministic and side-effect free.
5. Test representative objects and helper output.

## Failure modes

- hidden database queries during generation;
- route generation coupled to authorization;
- duplicate abstractions over ordinary helpers;
- unstable object mapping.

## Testing

Assert generated paths/URLs for representative objects and helper stability.

## Review checklist

- [ ] conventional helper considered first
- [ ] mapping explicit
- [ ] generation side-effect free
- [ ] helper output tested

## Related skills

rails-routing, rails-active-model, rails-action-view
