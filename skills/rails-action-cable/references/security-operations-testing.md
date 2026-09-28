# Security, operations, observability, and testing

Reference for the `rails-action-cable` skill. Load it on demand when a change has realtime security/privacy, deployment, observability, or test-strategy impact. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Security and privacy

WebSockets are long-lived authorization contexts.

Review:

- authentication lifetime;
- session/token revocation;
- allowed origins;
- cookie use;
- CSRF/authentication semantics for client actions;
- channel authorization;
- tenant isolation;
- stream naming;
- payload sensitivity;
- connection identifiers;
- logs/telemetry.

Allowed origin configuration is part of the WebSocket trust boundary.

Never put private resource data into a broadly shared broadcast.

Never log access tokens, cookies, authorization headers, or full sensitive payloads.

Use `rails-security` and `rails-security-engineering` for threat modeling and abuse-case analysis.

## Operational lifecycle

Deployments and restarts interrupt connections.

Define:

- drain/reconnect behavior;
- client retry/backoff;
- stale connection cleanup;
- readiness versus ability to accept new WebSockets;
- graceful shutdown;
- Redis connection cleanup;
- monitoring during deploys.

Avoid synchronized client reconnect storms after a fleet restart.

Use jittered client reconnect/backoff where the client supports configurable policy.

Coordinate deployment lifecycle with `rails-production-runtime`, `rails-release-engineering`, and `rails-incident-engineering`.

## Observability

Monitor lifecycle and throughput, not only exceptions.

Useful bounded signals:

- active connection count;
- subscription count;
- connection attempts/rejections;
- subscribe/unsubscribe counts;
- disconnect reason class;
- broadcast count;
- broadcast latency;
- payload byte buckets;
- failed broadcasts;
- Redis/pubsub errors;
- reconnect rate;
- per-channel hotness;
- consumer processing/failure where observable.

Avoid raw user IDs or stream names as unbounded metric labels.

Correlate channel actions and broadcasts with request/job/business-event IDs where safe.

Use `rails-observability` for telemetry design.

## Testing

Test at the smallest realtime boundary:

- connection authentication accepts authorized callers;
- unauthenticated connections are rejected;
- channel subscription authorization is correct;
- cross-tenant subscriptions are rejected;
- stream names are deterministic and isolated;
- broadcasts reach the intended channel;
- unauthorized channels receive nothing;
- client actions validate parameters/authorization;
- broadcast payload schema is stable;
- reconnect/resubscribe triggers reconciliation where required;
- channel unsubscribe cleans up correctly;
- provider/adapter failure degrades according to contract.

Use Action Cable test helpers where available and deterministic local adapters.

Do not make ordinary tests depend on a live Redis cluster.

For frontend consumer behavior, use focused client tests rather than testing browser rendering through every server-side channel test.
