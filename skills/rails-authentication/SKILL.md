---
name: rails-authentication
description: Use when adding, reviewing, or debugging Rails authentication, sessions, credentials, protected resources, or authentication-related integration.
---

# Rails Authentication

## Purpose

Preserve a clear authentication boundary without scattering identity/session logic through ordinary feature code.

## Activate when

- adding sign-in/sign-out
- protecting a resource
- changing session/token behavior
- integrating Devise or another existing authentication mechanism
- debugging authenticated request failures

## Repository inspection

Identify the actual mechanism first:

- authentication gem/library
- User/account/session models
- routes
- controller callbacks
- middleware if relevant
- token/session storage
- password/reset flows
- request tests
- authorization/policy layer if present

Do not invent a new authentication system when one already exists.

## Authentication versus authorization

Keep the distinction clear:

- authentication: who is the requester?
- authorization: may that requester perform this action?

A user being signed in does not imply permission to access every resource.

## Credentials and secrets

Never log or commit:

- passwords
- password hashes unnecessarily
- raw session secrets
- bearer tokens
- reset tokens
- private credentials

Follow the repository's secret management mechanism.

## Session/token behavior

Before changing authentication state, understand:

- session creation
- rotation/invalidation
- expiration
- logout semantics
- multi-device behavior if relevant
- CSRF protection for browser sessions
- API credential behavior for API endpoints

## Protected resources

Authentication checks should occur at the server boundary.

Do not rely on:

- hidden links
- client-side UI state
- disabled buttons
- route obscurity

for protection.

## Failure behavior

Verify repository conventions for:

- unauthenticated request
- invalid credentials
- expired session/token
- forbidden authenticated request
- not-found versus unauthorized information disclosure behavior

## Agent review checklist

- [ ] existing authentication system inspected
- [ ] authn/authz distinction preserved
- [ ] secret handling safe
- [ ] session/token lifecycle understood
- [ ] protected endpoints enforce server-side checks
- [ ] failure contract tested

## Verification

Use authentication/integration/request tests that exercise valid, invalid, expired, unauthenticated, and unauthorized cases relevant to the repository.

## Source foundation

The Ruby Workshop includes an authentication step in its Rails learning path. This skill turns that material into an agent procedure while deliberately requiring inspection of the repository's real authentication mechanism.
