# Password recovery, abuse controls, sensitive operations, and compromise response

Reference for the `rails-authentication` skill. Load it on demand when a change alters password reset, login throttling or lockout, re-authentication for sensitive operations, or compromise handling. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Password reset and recovery

Treat password reset as an authentication protocol, not ordinary CRUD.

Define:

1. reset request;
2. account lookup behavior;
3. enumeration-safe response;
4. token generation/storage;
5. token lifetime;
6. one-time-use semantics;
7. trusted delivery;
8. token consumption;
9. credential update;
10. session/token revocation after successful reset;
11. notification/audit;
12. abuse/rate limiting.

Reset tokens must not be logged or exposed through analytics, referrers, screenshots, or generic error reporting.

A password reset should not silently leave known-compromised sessions active unless that behavior is an explicit security decision.

## Login abuse controls

Authentication endpoints are public security boundaries.

Assess credential stuffing, password spraying, brute-force attempts, account enumeration, reset-email abuse, token replay, bot traffic, and distributed attacks.

Possible controls include rate limiting, progressive backoff, device/IP controls, challenges, generic failure messages, anomaly detection, notifications, and safe recovery.

Avoid permanent lockouts that become denial-of-service primitives unless explicitly justified.

Rate limits should reflect the threat model; one global IP limit is rarely sufficient.

## Security-sensitive operations

Some actions should require recent or fresh authentication even if a session exists.

Examples include password changes, MFA/security settings, API-key rotation, payout/payment destination changes, account deletion, and privilege changes.

Define a freshness requirement rather than assuming logged in is equivalent to recently authenticated.

Enforce freshness on the server.

Require recent authentication or explicit reauthentication when the repository's security contract demands it, including:

- password changes;
- API key/token rotation;
- MFA/security-setting changes;
- payment destination changes;
- account deletion;
- privilege changes.

Enforce this on the server. A frontend confirmation is not authentication evidence.

## Compromise response

Plan for leaked passwords, session cookies, reset tokens, API tokens, signing secrets, and credential-store exposure.

For each credential class define detection, revocation, rotation, session invalidation, notification, audit evidence, and recovery verification.

Do not assume changing the password invalidates every other credential type.

Authentication design must include an emergency response path:

1. identify affected credential classes;
2. revoke active sessions/tokens;
3. rotate compromised secrets;
4. require reauthentication where appropriate;
5. notify affected users according to policy;
6. retain non-secret audit evidence;
7. verify previously issued credentials fail;
8. document residual risk.

Do not assume password reset automatically revokes API tokens, remember-me credentials, or every device session unless the implementation explicitly guarantees it.
