# Connection authentication and lifecycle

Reference for the `rails-action-cable` skill. Load it on demand when a change alters connection identification, authentication, or connection lifecycle. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Connection authentication

Connection authentication establishes who owns a WebSocket connection.

The connection layer should answer:

- who is the caller?
- which account/tenant context is loaded?
- which connection identifiers are safe to expose to channel callbacks?
- what makes a connection unauthorized?
- how is authentication failure surfaced?
- how are credentials rotated or revoked?

Keep connection authentication narrow.

Do not place channel-specific authorization decisions in the connection merely because the user is authenticated.

Authentication proves identity; it does not grant subscription access.

Use `rails-security` and `rails-security-engineering` for authentication, session/token, tenant, and trust-boundary analysis.

## Connection lifecycle

A browser tab/device can create its own WebSocket connection.

Model lifecycle explicitly:

```text
connect
-> authenticate
-> establish connection
-> subscribe channels
-> receive broadcasts
-> disconnect
-> reconnect
-> resubscribe
```

Assume connections disappear without an orderly application-level shutdown because of browser lifecycle, mobile/network transitions, proxies, deploys, worker restarts, or provider failure.

Do not treat an in-memory connection registry as durable state.

If presence is required, define lease/expiry semantics rather than assuming `connected` means "user is online."
