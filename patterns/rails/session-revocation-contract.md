---
name: session-revocation-contract
description: Define authoritative revocation semantics for current-session, per-device, all-session, credential-change, and compromise flows.
family: rails
---

# Session Revocation Contract

## Problem

Logout or credential changes can appear successful while previously issued sessions or tokens remain valid.

## Use when

Adding logout, password change, global logout, device management, incident response, or credential rotation.

## Do not use when

There is no reusable authenticated session or token.

## Repository inspection

Inspect session/token records, revocation fields, caches, cookie/session stores, password-change paths, and active-device management.

## Implementation procedure

1. Identify the revocation source of truth.
2. Define current-session revoke.
3. Define per-device revoke.
4. Define revoke-all.
5. Define password-change behavior.
6. Define compromise response.
7. Define race behavior for in-flight requests.
8. Apply revocation to every credential class.
9. Add observability without logging credentials.
10. Add regression tests.

## Failure modes

- password change leaves bearer tokens active
- revoke-all updates one store but not another
- cached current-user state ignores revocation
- browser and API revocation semantics differ unexpectedly

## Testing

Test each revocation scope and verify rejected access after revocation.

## Review checklist

- [ ] source of truth explicit
- [ ] credential classes enumerated
- [ ] revoke scopes defined
- [ ] in-flight race considered
- [ ] regression tests present

## Related skills

- rails-authentication
- rails-security
- rails-api-integration
- rails-incident-engineering

