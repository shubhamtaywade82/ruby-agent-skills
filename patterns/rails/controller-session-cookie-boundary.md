---
name: controller-session-cookie-boundary
description: Use when controller behavior reads or writes sessions, cookies, or flash state.
family: rails
---

# Controller Session and Cookie Boundary

## Problem

HTTP state is easy to overuse. Large or sensitive session/cookie payloads create privacy, size, invalidation, and authorization risks.

## Use when

- implementing login state or short-lived UI state
- adding preference cookies
- changing flash behavior
- reviewing session payloads.

## Do not use when

- an authentication library owns session semantics and the controller does not alter them
- durable application state belongs in the database or another authoritative store.

## Repository inspection

Inspect session store, serializer, cookie configuration, authentication integration, secret rotation, and request tests.

## Implementation procedure

1. Classify data as identity, UI state, preference, or durable domain state.
2. Keep only minimal state in session/cookie.
3. Use signed/encrypted jars according to integrity/confidentiality needs.
4. Set expiration and deletion semantics deliberately.
5. Use flash only for transient user-facing messaging.
6. Never treat session/cookie presence as sufficient authorization.

## Failure modes

- storing models or large collections
- placing secrets or provider payloads in session
- using unsigned cookies for sensitive integrity decisions
- leaving stale identity state after logout or rotation.

## Testing

Assert set/read/delete behavior, meaningful expiry semantics, flash.now versus redirect flash, and unauthorized access despite forged or missing state.

## Review checklist

- [ ] payload is minimal
- [ ] integrity/confidentiality requirement is explicit
- [ ] lifecycle is defined
- [ ] authorization is authoritative elsewhere
- [ ] session/cookie tests exist

## Related skills

rails-action-controller, rails-authentication, rails-security, rails-test-engineering
