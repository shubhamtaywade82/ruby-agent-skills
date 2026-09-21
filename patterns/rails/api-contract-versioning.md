---
name: api-contract-versioning
description: Evolve a Rails API contract without silently breaking existing consumers.
family: rails
---

# API Contract Versioning

## Problem

An API representation or behavior must change while existing consumers may continue using the previous contract.

## Use when

Changing JSON shape, media type, field semantics, status-code behavior, pagination, authentication requirements, or other externally consumed behavior.

## Do not use when

The change is internal and has no externally observable contract impact.

## Repository inspection

Inspect Rails version, API namespaces/versioning, serializers/presenters, routes, client usage, schema/docs, and request/contract tests.

## Implementation procedure

1. Capture the current wire contract.
2. Classify the change as additive or breaking.
3. Search consumers and tests.
4. Use the repository's established versioning mechanism.
5. Isolate only the changed representation/behavior.
6. Keep shared domain logic shared where safe.
7. Test old/new contracts during coexistence.
8. Define deprecation/removal criteria.
9. Verify rollout compatibility.

## Failure modes

- removing or renaming fields silently
- changing types/nullability
- changing status semantics
- versioning every internal class
- duplicating the entire domain
- removing the old contract before consumers migrate

## Testing

Test both versions at the HTTP boundary when coexistence is required. Verify response shape, status, and important error behavior.

## Review checklist

- [ ] contract delta identified
- [ ] consumers checked
- [ ] versioning matches repository convention
- [ ] shared domain logic remains shared where safe
- [ ] coexistence tested
- [ ] deprecation/removal explicit

## Related skills

- rails-api-integration
- rails-routing
- rails-controllers
- ruby-api-design
- rails-testing
