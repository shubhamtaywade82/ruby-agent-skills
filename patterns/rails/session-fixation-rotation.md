---
name: session-fixation-rotation
description: Ensure successful authentication establishes a fresh session context and invalidates attacker-controlled pre-authentication state.
family: rails
---

# Session Fixation Rotation

## Problem

An attacker can cause a victim to authenticate inside a session identifier known to the attacker. Authentication without session renewal can preserve that attacker-controlled identity context.

## Use when

Changing login/session establishment, authentication concerns, remember-me flows, or session storage.

## Do not use when

The authentication boundary is token-only and has no reusable browser/session identifier.

## Repository inspection

Inspect pre-login session creation, login transition, reset_session or framework equivalent, cookie handling, and tests.

## Implementation procedure

1. Identify the pre-authentication session.
2. Identify the successful-login transition.
3. Issue a fresh session context.
4. Invalidate or retire prior authenticated authority as required.
5. Rebind current-user/session state to the new context.
6. Verify remember-me behavior does not reintroduce the old session.
7. Test the transition explicitly.

## Failure modes

- session ID reused after login
- old session remains usable
- only cookie value changes while server state remains shared
- fixation protection assumed but not verified

## Testing

Assert pre-login state cannot become the post-login authenticated session and that the old context is invalid.

## Review checklist

- [ ] fixation threat modeled
- [ ] fresh session issued
- [ ] old authority retired
- [ ] remember-me path reviewed
- [ ] transition test exists

## Related skills

- rails-authentication
- rails-security
- rails-action-controller

