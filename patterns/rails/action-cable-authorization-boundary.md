---
name: action-cable-authorization-boundary
description: Authorize realtime connections, subscriptions, streams, and state-changing channel actions.
family: rails
---
# Action Cable Authorization Boundary

## Problem
A valid connection is incorrectly treated as permission for every stream or action.

## Structure
Authorize identity at connection, resource access at subscription/stream, and sensitive mutations at action.

## Failure modes
Stream leakage, stale membership, and mutation without resource authorization.

## Testing
Cover unauthorized subscription and action attempts plus membership revocation.
