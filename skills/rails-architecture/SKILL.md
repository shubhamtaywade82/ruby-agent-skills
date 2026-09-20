---
name: rails-architecture
description: Use when implementing or reviewing Rails application structure, MVC boundaries, resource flows, REST behavior, or cross-layer feature changes.
---

# Rails Architecture

## Purpose

Map a Rails feature to the repository's existing request, domain, persistence, presentation, and integration boundaries.

## Activate when

- a feature crosses routes/controllers/models/views/services
- a new Rails resource is introduced
- an existing endpoint grows in scope
- application boundaries are unclear
- architecture is being refactored

## Repository inspection



Read the smallest useful slice of the repository:

```text
routes
  -> controller
  -> authorization/authentication
  -> domain/service/query
  -> model/database
  -> serializer/view
  -> tests
```

Also inspect:

- Gemfile/lockfile
- schema/migrations
- CI
- existing conventions
- background jobs/external services when involved

## MVC responsibilities

Rails' MVC model separates request handling, presentation, and persistence/domain behavior.

A controller should coordinate the request, not become a second domain layer.

Views should present.

Persistence models should represent persistence and domain behavior that naturally belongs there.

Services/domain objects/query objects should be introduced when the workflow or query responsibility is genuinely separate from the existing object.

## Thin controller / model responsibility

The source material describes the traditional "thin controller, richer model" Rails style. Preserve the intent—controllers should not contain substantial business logic—but do not interpret "fat model" as permission to turn Active Record models into catch-alls.

Repository conventions decide whether domain behavior belongs in models, services, form objects, policies, commands, or other boundaries.

## REST/resource design

Prefer conventional resources when they accurately represent the operation.

Use custom actions when standard resource semantics do not fit, and keep them explicit.

## Cross-layer procedure

1. trace the current request flow
2. identify the required behavior contract
3. identify the owner of each responsibility
4. reuse existing boundaries
5. implement the smallest coherent change
6. update focused tests
7. verify authorization, validation, persistence, and response behavior

## Architectural anti-patterns

- fat controllers
- Active Record models used as universal service objects
- duplicated business rules across controller/model/view
- introducing a service for a trivial single-object operation
- inventing a new layer when the repository has no need for it
- mixing unrelated refactors into a feature

## Agent review checklist

- [ ] request flow understood
- [ ] boundary ownership explicit
- [ ] existing conventions reused
- [ ] controller remains orchestration-focused
- [ ] persistence concerns are not duplicated
- [ ] cross-layer tests exist where the contract crosses layers
- [ ] architecture change is justified by actual complexity

## Verification

Trace the final feature end-to-end and run the appropriate request/model/system tests. Inspect the diff for responsibility leakage and accidental architectural expansion.

## Source foundation

Grounded in the MVC, Rails application anatomy, REST/CRUD, and Rails philosophy material in *The Ruby Workshop*, including DRY and convention-over-configuration. The boundary discipline is strengthened using *Clean Ruby*'s responsibility and refactoring guidance.
