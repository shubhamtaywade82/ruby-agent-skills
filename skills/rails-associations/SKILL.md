---
name: rails-associations
description: Use when designing or changing Active Record relationships including belongs_to, has_one, has_many, through, and HABTM.
---

# Rails Associations

## Purpose

Represent real domain relationships while preserving database integrity, lifecycle behavior, and predictable query semantics.

## Activate when

- adding/changing an association
- adding a foreign key/join table
- changing dependent behavior
- debugging association loading or deletion
- introducing a through relationship

## Repository inspection

Inspect:

- models
- schema
- foreign keys
- unique indexes
- nullability
- migrations
- dependent options
- validations
- factories/fixtures
- existing association traversal and query patterns

## Association choice

- `belongs_to`: the record contains the reference to the associated record.
- `has_one`: one associated record is expected from the parent's perspective.
- `has_many`: a collection of associated records.
- `has_many :through`: indirect collection through a join model.
- `has_one :through`: indirect singular relationship.
- `has_and_belongs_to_many`: direct many-to-many only when no join-model behavior is required and repository conventions support it.

Do not choose associations solely because the generated method names look convenient.

## Database integrity

Association definitions are not a substitute for:

- foreign keys
- unique indexes
- null constraints
- check constraints where applicable

Consider race conditions and concurrent writes.

## Dependent behavior

Before changing `dependent:`, determine what happens on:

- parent deletion
- child deletion
- orphaned references
- callbacks
- database cascades

Do not combine application callbacks and database cascades without understanding the resulting semantics.

## Loading and performance

Association traversal inside loops can create N+1 queries.

Consider eager loading/preloading when the call path demands it, but do not blindly eager-load every relationship.

## Through relationships

For `through` associations, inspect the join model and actual cardinality. Verify which side owns creation/deletion behavior.

## Agent review checklist

- [ ] cardinality matches domain
- [ ] foreign key path confirmed
- [ ] uniqueness/nullability considered
- [ ] dependent semantics explicit
- [ ] through/join behavior understood
- [ ] N+1 risk considered
- [ ] tests cover persistence and deletion behavior

## Verification

Test association reads/writes, invalid references, deletes, dependent behavior, and representative query paths. Add query-count/performance tests only when the repository uses them or performance is a material requirement.

## Source foundation

Derived from the Active Record associations material in *The Ruby Workshop*, with the broader integrity and responsibility approach applied by this skill based on the repository's actual schema.
