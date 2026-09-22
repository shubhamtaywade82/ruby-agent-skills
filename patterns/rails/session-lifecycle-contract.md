---
name: session-lifecycle-contract
description: Specify authenticated session creation, renewal, expiry, logout, and invalidation as explicit state transitions.
family: rails
---

# Session Lifecycle Contract

## Problem

Session behavior becomes unsafe when creation, renewal, logout, and expiry are implicit or implemented differently across endpoints.

## Use when

Changing browser sessions, database-backed sessions, session cookies, logout, expiry, device sessions, or current-user loading.

## Do not use when

The application has no session-based authentication boundary.

## Repository inspection

Inspect session model/store, cookies, controller concern, login/logout actions, expiry configuration, revocation fields, and tests.

## Implementation procedure

1. Model anonymous and authenticated states.
2. Define session creation.
3. Define post-login renewal/rotation.
4. Define authenticated request lookup.
5. Define inactivity/absolute expiry if required.
6. Define logout invalidation.
7. Define credential-change invalidation.
8. Define revoke-current and revoke-all semantics.
9. Define multi-device behavior.
10. Test each transition.

## Failure modes

- logout only clears UI state
- expired session still resolves current user
- login reuses pre-auth session
- revoke-all misses alternate session store
- device sessions cannot be distinguished safely

## Testing

Use request/system tests for login, protected request, logout, expiry, and revoked-session rejection.

## Review checklist

- [ ] state transitions explicit
- [ ] renewal/rotation explicit
- [ ] expiry explicit
- [ ] logout invalidates authority
- [ ] revoke scope explicit

## Related skills

- rails-authentication
- rails-action-controller
- rails-security
- rails-test-engineering

