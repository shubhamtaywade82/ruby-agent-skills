---
name: turbo-stream-broadcast-contract
description: Safely broadcast committed Turbo Stream updates to authorized subscribers.
family: rails
---
# Turbo Stream Broadcast Contract

## Problem
Broadcasts leak private data or publish state before it is durable.

## Structure
Broadcast only after committed state, use explicit stream naming, and preserve tenant/resource authorization.

## Failure modes
Pre-commit broadcasts, cross-tenant stream names, duplicate updates, and oversized payloads.

## Testing
Cover authorized subscriptions, target isolation, commit ordering, and replay/reconnect behavior where applicable.

## Do not use when
The interaction does not require multi-client realtime updates.

## Repository inspection
Inspect transaction boundaries, Action Cable streams, authorization, tenant naming, and event/broadcast tests.

## Implementation procedure
Publish after commit, derive stream identity from trusted context, bound payloads, and define reconnect/replay behavior.

## Failure modes
Pre-commit broadcast, cross-tenant leakage, duplicate updates, and durable-state confusion.

## Testing
Test authorization, commit ordering, target isolation, and duplicate/reconnect behavior where required.

## Review checklist
Durable state is authoritative and broadcast scope is explicit.

## Related skills
rails-hotwire, rails-action-cable, rails-event-driven-messaging, rails-reliability-engineering
