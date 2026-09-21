---
name: active-record-relation-composition
description: Use when building reusable, composable ActiveRecord::Relation logic.
family: rails
---

# Active Record Relation Composition

## Problem

Reusable query logic is often made less composable by returning arrays, embedding side effects, or hiding incompatible ordering/join assumptions.

## Use when

- composing model scopes
- creating query objects that return relations
- merging relation fragments.

## Do not use when

- the result is intentionally a materialized report/value list
- the query requires a workflow with external side effects.

## Repository inspection

Inspect existing scopes/query objects and their callers.

## Implementation procedure

1. Keep query-building methods relation-valued.
2. Compose with supported Relation APIs and merge where appropriate.
3. Avoid side effects during relation construction.
4. Document required joins/order/group preconditions.
5. Materialize only at the outer consumer boundary.

## Failure modes

- hidden database calls during composition
- relation methods returning inconsistent types
- duplicate joins
- contradictory ordering or limit semantics.

## Testing

Test chainability, relation type, representative composition, and terminal result behavior.

## Review checklist

- [ ] relation remains composable
- [ ] no unexpected SQL
- [ ] preconditions are explicit
- [ ] terminal execution is intentional

## Related skills

rails-active-record, ruby-api-design, rails-performance
