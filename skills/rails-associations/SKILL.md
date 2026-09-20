---
name: rails-associations
description: Use when designing or changing Active Record relationships such as belongs_to, has_one, has_many, through, or HABTM.
---

# Rails Associations

## Purpose

Represent actual domain relationships while making database ownership and loading behavior explicit.

## Inspect first

Read:
- schema and foreign keys
- existing models
- migrations
- validations/constraints
- dependent behavior
- tests and factories/fixtures

## Choose the relationship from domain facts

- `belongs_to` for a record that references an owning/associated record
- `has_one` when one associated record is expected
- `has_many` for one-to-many collections
- `has_many :through` when the relationship is represented through a join model
- `has_one :through` for a single indirect association
- `has_and_belongs_to_many` only where a direct many-to-many relationship without join-model behavior is actually appropriate

Do not select an association solely from the desired method name.

## Integrity

Verify:
- foreign keys
- nullability
- uniqueness where required
- dependent semantics
- delete/update behavior
- validation expectations

Model associations do not replace database integrity constraints.

## Loading and queries

Consider eager loading and query count for collection access. Check for N+1 behavior when association traversal is used in loops or views.

## Verification

Test:
- association shape
- persistence and deletion behavior
- invalid relationship states
- query behavior where performance is material

## Source foundation

Derived from the Active Record associations material in The Ruby Workshop.
