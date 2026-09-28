# Observability, audit, performance, and testing

Reference for the `rails-authentication` skill. Load it on demand when adding authentication audit/telemetry, reviewing capacity, or choosing and writing authentication tests. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Observability and audit

Authentication telemetry should support incident response without leaking secrets.

Useful events include login success/failure category, logout, session creation/revocation, reset requested/completed/failed, credential change, global revocation, and suspicious activity.

Keep dimensions bounded and safe.

Never log raw passwords, session cookies, bearer tokens, reset tokens, or Authorization headers.

Compose with rails-observability and rails-incident-engineering.

Record security-relevant events without credential material:

- login success/failure;
- logout;
- session creation/revocation;
- password-reset request/completion/failure;
- credential change;
- global revoke;
- throttling/abuse events;
- reauthentication;
- compromise response.

Use structured, bounded dimensions. Never log passwords, raw tokens, reset credentials, session cookies, or full authorization headers.

## Performance and capacity

Authentication can become a database and cryptographic hotspot.

Measure password hashing cost, login throughput, session lookup rate, session-table growth, reset-token queries, rate-limit storage, and authentication cache/store latency.

Do not reduce password hashing cost solely to improve latency without security review.

Use indexes for session/token lookup paths.

Avoid loading entire user graphs during every request authentication.

## Performance and reliability

Authentication is a public, potentially expensive boundary. Review password-hash cost, login/reset rate, session-store latency, token lookup indexes, distributed throttling capacity, and dependency failure behavior.

Do not weaken password hashing or security controls to solve capacity problems. Measure first and preserve fail-safe authentication semantics.

## Testing strategy

Authentication requires transition-focused tests.

### Credential verification

- valid credentials;
- invalid credentials;
- unknown account;
- disabled/suspended account;
- credential normalization.

### Session lifecycle

- anonymous request rejected;
- successful login creates authenticated state;
- authenticated request resolves expected principal;
- logout invalidates the session;
- expiry/revocation rejects stale state;
- session rotation occurs at the correct transition.

### Recovery

- reset request;
- enumeration-safe response;
- valid token;
- expired token;
- consumed token;
- invalid token;
- credential update;
- post-reset revocation behavior.

### Abuse

- rate-limit behavior;
- lockout/challenge behavior if present;
- repeated failures do not expose account existence.

### Boundary separation

- authentication does not bypass authorization;
- alternate endpoints/jobs cannot skip required authentication context;
- browser and API auth contracts remain distinct.

Prefer deterministic request/system tests and fake external mail/provider delivery at the narrow boundary.

Prefer deterministic transition-focused tests:

- valid login;
- invalid and missing credentials;
- protected request without identity;
- authenticated request;
- logout;
- expiry;
- revocation;
- session fixation transition;
- password reset valid/expired/replayed;
- post-reset revocation;
- remember-me issuance/expiry/revocation when supported;
- browser/API authentication and CSRF semantics;
- login/reset abuse thresholds;
- fresh/stale authentication for sensitive actions;
- actor propagation without credential serialization;
- multi-device revocation;
- compromise response.

Use fake clocks and repository-local transports where practical. Do not depend on live email providers or external identity providers for deterministic unit/request/system contracts.
