---
name: authentication-mechanism-boundary
description: Identify and preserve the repository's actual authentication mechanism before changing identity or session behavior.
family: rails
---

# Authentication Mechanism Boundary

## Problem

Authentication behavior may be split between Rails generated code, Devise, middleware, controller concerns, token adapters, and custom domain code. Changing one layer without mapping the whole mechanism can create duplicate or bypassable authentication paths.

## Use when

Adding or modifying login, session, password, token, recovery, or current-user behavior.

## Do not use when

The change is unrelated to establishing or consuming authenticated identity.

## Repository inspection

Inspect Rails/Ruby versions, authentication gems, models, concerns, controllers, middleware, routes, session/token storage, configuration, and tests.

## Implementation procedure

1. Identify the authoritative authentication mechanism.
2. Map credential verification.
3. Map principal construction.
4. Map session/token issuance.
5. Map request context loading.
6. Map logout/revocation.
7. Map recovery.
8. Map alternate paths such as API, jobs, and Action Cable.
9. Reuse existing framework boundaries instead of duplicating them.
10. Add regression coverage for the mechanism actually used.

## Failure modes

- parallel authentication systems
- custom code bypasses framework revocation
- current-user lookup disagrees with session ownership
- API and browser auth accidentally share incompatible semantics

## Testing

Test the real authentication entry point, request context, and logout/revocation path.

## Review checklist

- [ ] authoritative mechanism identified
- [ ] no duplicate auth path introduced
- [ ] principal/session lifecycle mapped
- [ ] alternate paths audited
- [ ] tests exercise actual mechanism

## Related skills

- rails-authentication
- rails-security
- rails-security-engineering

