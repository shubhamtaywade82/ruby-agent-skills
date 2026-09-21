---
name: action-cable-testing
description: Test Rails Action Cable connections, subscriptions, broadcasts, authorization, and reconnect contracts deterministically without live Redis.
family: testing
---

# Action Cable Testing

## Problem

Realtime regressions often hide in authorization, stream identity, broadcast routing, and lifecycle behavior rather than ordinary model/controller tests.

## Use when

- adding or changing Action Cable behavior;
- reviewing a realtime authorization or payload regression.

## Do not use when

- the feature has no Action Cable boundary.

## Repository inspection

Inspect test framework, Action Cable test helpers, channel/connection tests, adapter configuration, client tests, and authentication helpers.

## Implementation procedure

1. Test connection authentication.
2. Test channel authorization.
3. Test stream/subscription behavior.
4. Test broadcast routing and payload.
5. Test client actions.
6. Test reconnect/reconciliation semantics where relevant.
7. Use deterministic local/test adapters.
8. Keep cloud/Redis integration tests separate.

## Failure modes

- testing only that a channel class exists;
- missing cross-tenant tests;
- live Redis in ordinary CI;
- missing broadcast payload contract;
- no reconnect/reconciliation coverage.

## Testing

Prefer focused channel/connection tests and dedicated client contract tests.

## Review checklist

- [ ] connection auth
- [ ] channel auth
- [ ] stream identity
- [ ] broadcast payload
- [ ] reconnect
- [ ] deterministic adapter

## Related skills

rails-action-cable, rails-test-engineering, rails-testing, rails-security
