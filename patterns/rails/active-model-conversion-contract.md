
---
name: active-model-conversion-contract
description: Define Active Model conversion, naming, key, and URL semantics for Rails-facing non-persisted objects.
family: rails
---

# Active Model Conversion Contract

## Problem

A plain object can accidentally appear persisted or produce unstable URLs/forms if model conversion semantics are implicit.

## Use when

- using form builders or polymorphic routes with Active Model;
- implementing to_model, to_key, to_param, or model_name.

## Do not use when

- the object is never consumed by Rails model-aware helpers.

## Repository inspection

Inspect routes, form builders, object rendering, persisted? semantics, model names, and URL tests.

## Implementation procedure

1. Define persisted versus transient state.
2. Define key availability.
3. Define URL parameter semantics.
4. Define model naming and route key.
5. Verify form/routing consumers.
6. Add conversion tests.

## Failure modes

- transient object returns a durable-looking key;
- authorization inferred from to_param;
- route helper targets the wrong model name;
- form submission uses unintended parameter nesting.

## Testing

Test to_model, persisted?, to_key, to_param, model_name, and the actual form/route consumer.

## Review checklist

- [ ] persistence semantics explicit
- [ ] key semantics explicit
- [ ] naming/route semantics explicit
- [ ] authorization not derived from URL
- [ ] consumer tests exist

## Related skills

- skills/rails-active-model/SKILL.md
- skills/rails-routing/SKILL.md
- skills/rails-action-view/SKILL.md
