---
name: route-constraint-contract
description: Use when adding segment, request, host, subdomain, format, or custom Rails routing constraints.
family: rails
---

# Route Constraint Contract

## Problem

Constraints can make dispatch precise, but expensive or overly broad constraints can create incorrect matches, hidden behavior, and runtime cost.

## Use when

- constraining IDs or slugs;
- routing by host/subdomain/format;
- adding custom matches? objects or lambda constraints.

## Do not use when

- the rule is authorization or domain validation;
- the request can be handled deterministically after dispatch.

## Repository inspection

Inspect request methods used by constraints, expected value types, route order, host/format conventions, and tests.

## Implementation procedure

1. State the request dimension that distinguishes the route.
2. Prefer simple segment/request constraints.
3. Keep custom constraints deterministic, side-effect free, and cheap.
4. Ensure constraint values match request API return types.
5. Test matching and non-matching requests.

## Failure modes

- constraint used as authorization;
- database/network work inside matches?;
- mismatched request value types;
- route never matches because of format/host assumptions;
- expensive constraints on hot paths.

## Testing

Exercise representative matching and non-matching requests and verify the dispatched route.

## Review checklist

- [ ] routing dimension explicit
- [ ] no authorization logic
- [ ] no side effects
- [ ] value types match
- [ ] negative case tested

## Related skills

rails-routing, rails-security, rails-action-controller
