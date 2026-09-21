---
name: polymorphic-association-boundary
description: Use when implementing or reviewing polymorphic Active Record associations and their type discriminator.
family: rails
---

# Polymorphic Association Boundary

## Problem

Polymorphic associations store both an identifier and a type, which creates compatibility, security, and lifecycle coupling across multiple model classes.

## Use when

- adding belongs_to polymorphic
- adding has_many through a polymorphic relation
- changing polymorphic type names.

## Do not use when

- the target type set is fixed and a normal foreign key is clearer.

## Repository inspection

Inspect type/id columns, indexes, migrations, allowed target classes, APIs, serializers, and authorization.

## Implementation procedure

1. Define the finite set of supported target classes.
2. Keep type values out of untrusted direct constantization.
3. Index the discriminator/id combination as appropriate.
4. Define deletion and authorization semantics per target class.
5. Plan class-renaming or migration compatibility.

## Failure modes

- arbitrary type constantization
- client-controlled class names
- missing type/id indexing
- inconsistent authorization across target classes.

## Testing

Test each allowed type, unsupported type, cross-tenant target, deletion, and serialization path.

## Review checklist

- [ ] allowed types are explicit
- [ ] type input is bounded
- [ ] indexes are appropriate
- [ ] authorization is target-aware
- [ ] rename/migration behavior is known

## Related skills

rails-associations, rails-security, rails-database-engineering, rails-zeitwerk
