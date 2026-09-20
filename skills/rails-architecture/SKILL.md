---
name: rails-architecture
description: Use when implementing Rails features involving controllers, routes, REST endpoints, MVC boundaries, views or application structure.
---

# Rails Architecture

## Inspect first
Inspect routes, controller, models, services/queries/policies, serializers/views, tests, authentication/authorization conventions and database structure before changing a feature.

Do not invent a new pattern if the application already has an established one.

## MVC responsibilities
Controllers receive requests, coordinate application behavior and return responses. Avoid substantial business rules in controllers.

Domain behavior belongs with the domain concept when it is naturally expressed there. A service is useful for workflows spanning multiple concepts or external boundaries.

Presentation concerns stay in views/serializers.

## REST
Prefer conventional resource routes/actions when they express the behavior accurately.

## Change procedure
1. identify the request/resource flow
2. inspect project conventions
3. choose responsibility boundaries
4. implement the smallest coherent change
5. add appropriate tests
6. verify authorization and validation behavior

## Source foundation
Uses MVC, Rails application anatomy, CRUD and REST foundations from The Ruby Workshop. Modern separation should follow the actual codebase rather than a rigid doctrine.