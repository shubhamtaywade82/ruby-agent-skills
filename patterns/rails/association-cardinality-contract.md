---
name: association-cardinality-contract
description: Use when defining or reviewing the cardinality and ownership contract of Active Record associations.
family: rails
---

# Association Cardinality Contract

## Problem

Association declarations can imply one-to-one, one-to-many, or many-to-many relationships without the database actually enforcing that shape.

## Use when

- adding belongs_to, has_one, or has_many
- changing foreign-key ownership
- reviewing one-to-one invariants.

## Do not use when

- the task is only query composition or migration mechanics.

## Repository inspection

Inspect both models, foreign key columns, nullability, indexes, uniqueness, and existing data.

## Implementation procedure

1. State the intended cardinality.
2. Identify the owning foreign key.
3. Determine whether absence is valid.
4. Add database enforcement where cardinality is an integrity requirement.
5. Add relationship behavior tests.

## Failure modes

- has_one without uniqueness enforcement
- nullable foreign key where presence is required
- assuming generated association methods enforce integrity.

## Testing

Test zero, one, and multiple associated rows where relevant and verify database constraints for hard invariants.

## Review checklist

- [ ] cardinality is explicit
- [ ] foreign-key ownership is correct
- [ ] database enforcement exists for hard invariants
- [ ] edge cardinalities are tested

## Related skills

rails-associations, rails-database-engineering, rails-active-record
