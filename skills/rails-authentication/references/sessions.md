# Sessions, fixation, revocation, cookies, remember-me, and devices

Reference for the `rails-authentication` skill. Load it on demand when a change alters session establishment, rotation, expiry, revocation, cookies, remember-me, or multi-device sessions. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Session lifecycle

For browser authentication define:

- session creation;
- session renewal/rotation;
- expiry;
- inactivity timeout if required;
- absolute lifetime if required;
- logout invalidation;
- credential-change invalidation;
- global session revocation;
- multi-device semantics.

Rails security guidance explicitly treats session fixation, session hijacking, CookieStore replay, session expiry, and secret rotation as authentication/security concerns.

A successful login must not preserve attacker-controlled pre-authentication session state.

Use reset_session or the authentication framework's equivalent when the framework contract requires session renewal after authentication.

Define the complete lifecycle:

- anonymous request;
- session creation;
- successful-login renewal;
- request-time principal resolution;
- inactivity expiry;
- absolute/session-age expiry where required;
- logout;
- current-session revocation;
- per-device revocation;
- global revocation;
- password-change/reset effects;
- compromise response.

Do not equate clearing browser state with server-side logout. The repository's authentication authority must be invalidated according to its session model.

Rails documents CookieStore as encrypted by default, but session data remains client-side and is constrained by cookie size and replay/security considerations. Keep only appropriate session state in the cookie and store durable business state server-side.

## Session fixation and rotation

Session fixation is distinct from session theft.

The critical invariant is:

> Successful authentication establishes a fresh authenticated session context that is not attacker-controlled.

Review pre-login session identifiers, the login transition, session renewal, old-session invalidation, remember-me behavior, and browser/proxy behavior.

Test the transition, not only the final authenticated page.

## Session revocation

Define the revocation source of truth.

Possible mechanisms include database-backed session deletion, session version/timestamp checks, credential-version checks, token denylists, or short-lived credentials with refresh-token rotation.

For multi-device systems distinguish:

- revoke current session;
- revoke one device;
- revoke all sessions;
- revoke on password change;
- revoke on suspected compromise.

Make revocation race behavior explicit. Security-sensitive operations may require a stronger freshness check than ordinary requests.

## Cookie and browser session contract

Review Secure, HttpOnly, SameSite, domain/path scope, expiry, and environment differences.

Rails CookieStore is encrypted/signed, but sensitive or highly mutable business state should not be placed in a client-side session merely because the cookie is protected.

Respect cookie size limits.

Keep secret_key_base and related secrets outside source control and use the repository's secrets mechanism.

Understand that rotating authentication secrets can invalidate existing encrypted/signed session material.

## Remember-me and persistent login

Persistent authentication changes the threat model.

Document token format/storage, lifetime, rotation, revocation, device scope, logout behavior, credential-change behavior, and stolen-token response.

Do not place a long-lived bearer credential into an opaque cookie without a revocation and rotation model.

## Multi-device session management

If users can be signed in on multiple devices, define session ownership, device metadata, last activity, session listing, per-device revoke, revoke-all, and expiry.

Treat device/session metadata as security-sensitive and minimize stored values.

When sessions are persisted server-side, model device/session ownership explicitly:

user
  ├─ session A / device A
  ├─ session B / device B
  └─ session C / device C

Define whether the application supports:

- revoke current device;
- revoke one device;
- revoke all devices;
- password-change invalidation;
- compromise-triggered global revocation;
- device/session visibility.

User-agent and IP information may be useful context and audit metadata, but should not silently become a strong identity proof.
