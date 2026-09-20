---
name: rails-authentication
description: Use when adding, reviewing or debugging Rails authentication flows, protected resources, sessions or authentication-related integration.
---

# Rails Authentication

## Purpose

Protect application access using the repository's established authentication mechanism without scattering authentication logic through feature code.

## Inspect first

Identify:
- authentication gem/library or custom mechanism
- user/session model
- routes and callbacks
- protected controllers
- current sign-in/sign-out flow
- authorization boundary if present
- tests and fixtures/factories

Do not invent an authentication system if the repository already has one.

## Boundary rules

- Authentication establishes who the requester is.
- Authorization determines whether that requester may perform the operation.
- Keep these concerns distinguishable even when the project implements them together.

## Implementation

Follow the existing mechanism for:
- session/token handling
- password storage
- reset flows
- callbacks
- protected routes
- unauthenticated responses

Never log passwords, raw tokens or credentials.

## Verification

Cover:
- authenticated access
- unauthenticated access
- sign-in/sign-out behavior
- invalid credentials
- session/token expiration or invalidation when relevant
- protected endpoint behavior

## Source foundation

The Ruby Workshop includes an authentication step in its Rails application activity. This skill turns that concept into a reusable agent procedure while requiring the repository's actual authentication mechanism to be inspected first.
