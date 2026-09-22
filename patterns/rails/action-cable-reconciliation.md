---
name: action-cable-reconciliation
description: Reconcile missed realtime state after disconnects, reconnects, or transient pub/sub failures.
family: rails
---

# Action Cable Reconciliation

## Problem

Action Cable broadcastings are time-dependent, so clients can miss updates while disconnected.

## Use when

- live UI state must remain accurate across reconnects;
- broadcasts are not durable.

## Do not use when

- the feature intentionally allows missed notifications and state can be stale.

## Repository inspection

Inspect authoritative HTTP/API state, client connection lifecycle, version/sequence fields, subscription callbacks, and broadcast contract.

## Implementation procedure

1. Identify authoritative current state.
2. Define reconnect trigger.
3. Re-establish subscriptions.
4. Refetch or request a snapshot.
5. Compare version/sequence where available.
6. Apply live updates after reconciliation.
7. Test missed-broadcast scenarios.

## Failure modes

- reconnect assumes broadcasts were replayed;
- stale UI accepted as authoritative;
- race between refetch and live messages;
- no recovery after subscription failure.

## Testing

Simulate missed broadcasts, reconnect, duplicate subscription, and reconciliation.

## Review checklist

- [ ] authoritative state
- [ ] reconnect trigger
- [ ] resubscribe
- [ ] snapshot/refetch
- [ ] race handling
- [ ] test

## Related skills

rails-action-cable, rails-api-integration, rails-event-driven-messaging, rails-reliability-engineering
