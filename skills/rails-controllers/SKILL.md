---
name: rails-controllers
description: Use when implementing or reviewing Rails controller actions, request handling, parameters, responses, redirects, rendering or controller boundaries.
---

# Rails Controllers

## Purpose

Coordinate HTTP requests without turning controllers into business-logic containers.

## Inspect first

Read the action, route, model/service collaborators, authorization conventions, serializers/views, request tests and nearby controllers.

## Controller responsibilities

A controller should primarily:
- receive the request
- authorize or coordinate according to local conventions
- validate/normalize boundary input
- invoke domain/application behavior
- render or redirect an appropriate response

Keep substantial business rules outside the controller.

## Parameters

- Use the application's established parameter filtering pattern.
- Treat external input as untrusted.
- Keep parameter normalization explicit.
- Do not duplicate model/domain validation in controller code without a clear boundary reason.

## Responses

Verify:
- status code
- redirect/render behavior
- response format
- error response shape
- authorization behavior

Do not change response contracts accidentally during refactoring.

## Action design

Prefer conventional CRUD actions when the behavior fits them. If an action becomes a workflow with multiple concepts, move the workflow into an appropriate domain/service boundary.

## Verification

Add or update request/controller tests covering success, invalid input, authorization and failure paths relevant to the action.

## Source foundation

Derived from Action Controller, MVC, CRUD and form/request flow material in The Ruby Workshop, constrained by the book's clean-code principles and the repository's established patterns.
