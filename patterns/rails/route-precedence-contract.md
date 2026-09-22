---
name: route-precedence-contract
description: Use when adding or reordering Rails routes where earlier generic routes can shadow later specific routes.
family: rails
---

# Route Precedence Contract

## Problem

Rails matches routes in declaration order, so a broad route can capture a path intended for a later, more specific route.

## Use when

- adding literal routes near dynamic resources;
- debugging an unexpected controller/action match;
- reviewing route-table changes with overlapping path shapes.

## Do not use when

- there is no overlapping recognition space;
- the issue is solely controller authorization or business logic.

## Repository inspection

Inspect config/routes.rb, route-loader files, neighboring dynamic segments, HTTP verbs, constraints, and existing route tests. Confirm the effective route table with bin/rails routes.

## Implementation procedure

1. Identify the desired request signature.
2. List earlier routes capable of recognizing that request.
3. Prefer structural clarification over arbitrary constraints.
4. Place specific routes before broader routes when both intentionally coexist.
5. Add a regression test for positive and negative matching.

## Failure modes

- literal path shadowed by :id;
- catch-all route placed too early;
- route order changed during refactor;
- constraint added merely to hide a precedence defect.

## Testing

Test the shadowing request and the generic route's ordinary case. Verify actual recognition.

## Review checklist

- [ ] overlapping signatures identified
- [ ] order is intentional
- [ ] positive/negative behavior tested
- [ ] no unnecessary constraint added

## Related skills

rails-routing, rails-action-controller, rails-testing
