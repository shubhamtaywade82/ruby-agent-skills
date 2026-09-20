---
name: rails-routing
description: Use when adding, changing or debugging Rails routes, resources, URL helpers, HTTP verbs or controller dispatch.
---

# Rails Routing

## Purpose

Make request-to-controller dispatch predictable and aligned with the application's resource model.

## Inspect first

Read:
- `config/routes.rb`
- neighboring routes
- controller action names
- existing URL helpers
- request/route tests
- namespace/version conventions

Use `bin/rails routes` when the route table needs verification.

## Decision rules

- Prefer resource-oriented routes when the domain fits them.
- Reuse existing resources/namespaces instead of creating duplicate paths.
- Keep route names descriptive and stable.
- Use custom member/collection routes only when standard REST actions do not express the behavior.
- Match HTTP verbs to semantics.
- Avoid route ambiguity and broad catch-all routes.

## Change procedure

1. identify the desired public URL and HTTP verb
2. locate the owning resource/controller
3. inspect existing routes for overlap
4. make the smallest route change
5. verify generated helpers
6. test dispatch and authorization-sensitive cases

## Failure modes

- duplicate routes with different behavior
- wrong HTTP verb
- action exists but route never reaches it
- helper name collisions
- namespace/version mismatch

## Verification

Run `bin/rails routes` and focused request/route tests.

## Source foundation

Derived from the routing, root-route and resource material in The Ruby Workshop.
