---
name: rails-routing
description: Use when adding, changing, or debugging Rails routes, resources, namespaces, URL helpers, HTTP verbs, or controller dispatch.
---

# Rails Routing

## Purpose

Make request dispatch explicit, conventional, and compatible with the application's public interface.

## Activate when

- adding an endpoint
- changing a resource route
- adding member/collection actions
- changing namespaces/API versions
- debugging routing or URL helper behavior

## Repository inspection

Inspect:

- `config/routes.rb`
- neighboring resource declarations
- controller namespaces/actions
- URL helper usage
- route/request tests
- authentication constraints
- API versioning conventions

Use `bin/rails routes` when route resolution is uncertain.

## Decision rules

Prefer `resources`/`resource` when the domain is naturally resource-oriented.

Use custom routes when:

- the operation is not a conventional CRUD action
- a member/collection operation has clear domain meaning
- the repository already uses a consistent custom-action convention

Use the correct HTTP verb for the operation's semantics and existing contract.

## Route naming

Stable helper names matter. Avoid collisions and unnecessary path aliases.

For namespaces/versioning, follow existing conventions rather than inventing a new URL hierarchy.

## Dispatch troubleshooting

When a route does not work, verify:

1. route declaration exists
2. route order does not shadow it
3. HTTP verb matches
4. path parameters match
5. controller namespace/action exists
6. constraints are satisfied
7. helper is the expected one

## Security boundary

Routing is not authorization.

A route being reachable does not imply the requester is permitted to perform the action. Keep authentication/authorization explicit.

## Anti-patterns

- duplicate routes with divergent behavior
- catch-all routes that shadow intended paths
- custom verbs used to compensate for unclear resource design
- route names coupled to implementation details
- assuming route existence means endpoint correctness

## Agent review checklist

- [ ] route is discoverable in route table
- [ ] verb/path semantics correct
- [ ] helper names are stable
- [ ] namespace/version matches project
- [ ] route ordering checked
- [ ] authentication/authorization boundaries remain intact

## Verification

Run `bin/rails routes`, focused route/request tests, and endpoint tests where applicable. Verify the generated helper and actual dispatch behavior rather than only inspecting `routes.rb`.

## Source foundation

Derived from the Rails routes, resources, root-route, and application-flow material in *The Ruby Workshop*.
