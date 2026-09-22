---
name: remember-me-contract
description: Define persistent-login credentials, rotation, device scope, logout behavior, expiration, and replay response.
family: rails
---

# Remember Me Contract

## Problem

Persistent login turns a short-lived browser session into a longer-lived bearer credential and therefore needs an explicit revocation model.

## Use when

Adding remember-me cookies, persistent sessions, device trust, or long-lived login credentials.

## Do not use when

All authentication expires with the browser session.

## Repository inspection

Inspect persistent-login token storage, cookie configuration, rotation, revocation, password-change behavior, and device management.

## Implementation procedure

1. Define credential lifetime.
2. Define token storage/digest strategy.
3. Define device ownership.
4. Rotate credentials on use when appropriate.
5. Revoke on logout/password change/compromise as required.
6. Define stolen-token response.
7. Protect logs and analytics.
8. Add replay/revocation tests.

## Failure modes

- forever-valid bearer cookie
- raw token persisted
- logout does not revoke persistent credential
- password change leaves persistent tokens active

## Testing

Test issuance, reuse/rotation, logout, credential change, expiry, and stolen-token rejection.

## Review checklist

- [ ] lifetime explicit
- [ ] revocation explicit
- [ ] rotation explicit
- [ ] token not logged
- [ ] replay test exists

## Related skills

- rails-authentication
- rails-security
- rails-action-controller

