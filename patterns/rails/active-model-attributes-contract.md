
---
name: active-model-attributes-contract
description: Define typed attributes, defaults, casting, and serialization semantics for Active Model objects.
family: rails
---

# Active Model Attributes Contract

## Problem

Transient models need predictable attribute types without relying on Active Record columns.

## Use when

- using ActiveModel::Attributes;
- adding typed/default attributes to a form/model object.

## Do not use when

- plain Ruby accessors are sufficient;
- database persistence is the owning concern.

## Repository inspection

Inspect supported Rails version, existing attribute declarations, custom types, input sources, and tests.

## Implementation procedure

1. Define the logical type.
2. Define nil/default behavior.
3. Define accepted source representations.
4. Verify casted values.
5. Keep validation separate from casting.
6. Test malformed, blank, nil, default, and repeated assignments.

## Failure modes

- assuming cast success means semantic validity;
- unexpected boolean/date/number coercion;
- mutable default leakage;
- custom type added without necessity.

## Testing

Test raw input, cast value, default, nil behavior, and invalid-domain values.

## Review checklist

- [ ] type explicit
- [ ] default explicit
- [ ] nil semantics explicit
- [ ] validation separate
- [ ] casting tests exist

## Related skills

- skills/rails-active-model/SKILL.md
- skills/rails-validations/SKILL.md
- skills/ruby-runtime-compatibility/SKILL.md
