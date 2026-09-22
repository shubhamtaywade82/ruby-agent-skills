---
name: authentication-freshness-boundary
description: Require recent or fresh authentication for high-impact security operations while preserving ordinary session semantics.
family: rails
---

# Authentication Freshness Boundary

## Problem

A valid long-lived session may not be sufficient evidence for changing security-sensitive credentials or privileged settings.

## Use when

Protecting password changes, API-key rotation, MFA/security settings, payment destination changes, account deletion, or privilege changes.

## Do not use when

Ordinary low-risk actions have no meaningful freshness requirement.

## Repository inspection

Inspect session age, reauthentication mechanisms, sensitive controllers, security policies, and audit events.

## Implementation procedure

1. Enumerate sensitive actions.
2. Define required freshness window or explicit reauthentication.
3. Define the evidence that satisfies freshness.
4. Prevent UI-only enforcement.
5. Handle expired freshness safely.
6. Audit successful and failed reauthentication.
7. Test stale-session and fresh-session behavior.

## Failure modes

- logged in treated as recently authenticated
- freshness check only in frontend
- sensitive endpoint accepts stale session
- freshness state survives global revocation incorrectly

## Testing

Test fresh success, stale rejection, reauthentication success, and revoked-session behavior.

## Review checklist

- [ ] sensitive actions enumerated
- [ ] freshness requirement explicit
- [ ] server-side enforcement
- [ ] revocation interaction considered
- [ ] audit/test coverage

## Related skills

- rails-authentication
- rails-security
- rails-security-engineering

