---
name: realtime-authorization-composition
description: Realtime Authorization Composition Contract
family: security
---
# Realtime Authorization Composition Contract

## Problem
Realtime connections can outlive authorization changes and expose streams or mutations.

## Use when
Action Cable or another realtime channel is protected.

## Do not use when
A channel carries only public information and cannot cause sensitive side effects.

## Repository inspection
Inspect connection identity, subscription parameters, streams, channel actions, and membership revocation.

## Implementation procedure
Authorize connection, resource/subscription, and sensitive action at appropriate boundaries; stop revoked streams.

## Failure modes
Stream leakage, stale membership, mutation without resource authorization.

## Testing
Test unauthorized subscriptions, revocation, reconnect, and sensitive actions.

## Review checklist
[ ] connection auth [ ] stream auth [ ] mutation auth [ ] revocation

## Related skills
rails-cross-boundary-authorization-security, rails-action-cable, rails-authorization