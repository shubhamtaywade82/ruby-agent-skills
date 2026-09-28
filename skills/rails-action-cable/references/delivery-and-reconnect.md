# Delivery semantics and reconnect

Reference for the `rails-action-cable` skill. Load it on demand when a change depends on delivery guarantees, missed messages, or client reconnect/resubscribe. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Realtime is not durable delivery

Action Cable broadcastings are time-dependent online delivery.

A disconnected client does not receive a broadcast emitted while it was offline.

Therefore distinguish:

```text
realtime notification
vs
durable business message
```

Use Action Cable for freshness/interaction where missed messages can be reconstructed or safely ignored.

Use Active Job or durable messaging/event infrastructure when delivery itself is business-critical.

Do not use Action Cable as a durable queue.

Do not build durable workflow semantics by assuming Action Cable broadcast history exists.

A robust UI often combines:

```text
initial authoritative HTTP fetch
+
Action Cable live updates
+
reconciliation/refetch after reconnect
```

This pattern makes reconnect gaps explicit.

## Client reconnect and resubscribe

Assume reconnects and duplicate subscription attempts.

The client may reconnect after:

- network failure;
- browser sleep/wake;
- mobile handoff;
- deploy/restart;
- proxy timeout;
- server failure.

Design subscriptions to be safely re-established.

On reconnect, determine whether the client must:

- refetch current state;
- re-subscribe;
- request a snapshot;
- reconcile missed state changes.

Do not claim a single broadcast after reconnect repairs all missed state.

Do not assume a single broadcast after reconnect repairs all missed state.

Where a monotonic version/sequence is available, use it to detect stale client state and trigger reconciliation.
