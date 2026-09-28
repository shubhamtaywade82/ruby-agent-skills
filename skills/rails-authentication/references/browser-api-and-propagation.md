# Browser versus API authentication, context propagation, callbacks, and failure contracts

Reference for the `rails-authentication` skill. Load it on demand when a change adds API/token authentication, propagates the actor to jobs or services, adds authentication hooks, or changes failure responses. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Browser authentication versus API authentication

Classify endpoints before changing authentication.

| Boundary | Typical credential | Key concerns |
|---|---|---|
| Browser HTML | session cookie | CSRF, cookie attributes, fixation, logout |
| Browser JSON | session cookie | CSRF and response contract |
| First-party API | bearer/session/token | leakage, expiry, revocation |
| Third-party API | API key/OAuth token | provider boundary and rotation |
| Service-to-service | service credential | workload identity, scope, rotation |

Do not blindly reuse browser session semantics for machine clients.

Do not disable CSRF protections simply because an endpoint returns JSON; classify the authentication boundary first.

Classify each boundary explicitly:

- browser session/cookie authentication;
- API bearer/opaque-token authentication;
- service-to-service credentials;
- WebSocket connection authentication.

Do not disable CSRF globally to accommodate JSON requests. Determine whether the endpoint is cookie-authenticated, token-authenticated, or deliberately mixed, and give each credential class explicit expiry, revocation, and failure semantics.

## Authentication context propagation

Authenticated context can cross controllers, service objects, jobs, mailers, Action Cable, events, and downstream services.

Separate user actor attribution, tenant attribution, authorization context, credential material, and correlation identifiers.

Never serialize passwords, session cookies, bearer tokens, reset tokens, or live authentication objects into jobs/events.

A background job should not silently impersonate a live browser session.

If a job performs an authorization-sensitive action, pass stable actor identity and re-evaluate authorization against current state where required.

When an authenticated request crosses into a job, mailer, event, Action Cable action, or service:

- propagate stable actor/tenant identifiers only when needed;
- never serialize passwords, session cookies, bearer tokens, or reset credentials;
- re-resolve the principal at execution time;
- re-evaluate authorization at the destination boundary;
- define deleted/disabled principal behavior;
- preserve correlation identifiers separately from authentication material.

Actor attribution is not authorization. A background job carrying a user ID must still enforce the destination operation's authorization policy.

## Authentication callbacks and hooks

Callbacks can be useful for narrow lifecycle hooks but dangerous when they hide security state transitions.

Prefer explicit ownership for session issuance, credential change, session revocation, recovery, and audit events.

If callbacks are used, document trigger, ordering, transaction semantics, failure behavior, and bypass paths.

Do not make credential security depend on a model callback if bulk SQL or alternate writers can bypass it.

## Failure contracts

Define behavior for missing credentials, malformed credentials, wrong credentials, disabled/suspended users, expired sessions, revoked sessions, expired/reset tokens, consumed reset tokens, rate-limited login, unauthorized authenticated requests, and stale authentication context.

Keep responses safe against account enumeration.

Do not conflate unauthenticated, forbidden, and deliberately hidden resource responses; use repository-specific HTTP/error conventions.

Define and test the behavior for:

- missing credential;
- invalid credential;
- expired credential;
- revoked credential;
- disabled/deleted principal;
- invalid/expired/replayed password reset;
- throttled login;
- authenticated but unauthorized action.

Authentication failure and authorization failure are different contracts. Resource-not-found behavior may also be deliberately different where information disclosure is a concern.
