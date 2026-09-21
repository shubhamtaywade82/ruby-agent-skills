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
