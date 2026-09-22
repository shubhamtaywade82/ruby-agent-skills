---
name: nested-route-boundary
description: Use when mapping parent-child resource addressing and deciding whether nested or shallow routing is the correct public contract.
family: rails
---

# Nested Route Boundary

## Problem

Nested routes can express parent context but become brittle when every member URL carries parent identifiers or when associations are mistaken for URL identity.

## Use when

- adding child resources under a parent;
- reviewing deep nesting;
- deciding between nested and shallow routes.

## Do not use when

- the URL is not scoped by a parent;
- only association behavior is changing.

## Repository inspection

Inspect relationship ownership, authorization/tenant rules, existing URLs/helpers, controller parameters, and route tests.

## Implementation procedure

1. State why parent identity is required.
2. Nest collection routes only when parent context is part of the public contract.
3. Use shallow member routes when the child is otherwise uniquely addressable.
4. Keep nesting at a comprehensible depth.
5. Test routing and authorization separately.

## Failure modes

- deeply nested helper signatures;
- parent ID carried without semantic purpose;
- URL nesting used as authorization;
- member URLs coupled to unstable parent relationships.

## Testing

Assert generated nested collection/member paths and shallow member paths where used. Add request tests for parent mismatch and authorization boundaries.

## Review checklist

- [ ] parent context is semantically required
- [ ] nesting depth is justified
- [ ] shallow routing evaluated
- [ ] authorization is independent
- [ ] helpers and params tested

## Related skills

rails-routing, rails-associations, rails-authentication, rails-security
