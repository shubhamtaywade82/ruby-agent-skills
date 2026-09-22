---
name: action-view-partial-contract
description: Define stable Action View partial inputs, outputs, and rendering responsibilities.
family: rails
---

# Action View Partial Contract

## Problem

Partials become fragile when they depend on implicit instance variables or undocumented locals.

## Use when

- creating or refactoring shared partials;
- introducing collection or object rendering;
- fixing missing-local or inconsistent-partial behavior.

## Do not use when

- the view is a one-off and already has an obvious local interface.

## Repository inspection

Inspect neighboring partials, local naming, object rendering, strict-local conventions, view tests, and presenters.

## Implementation procedure

1. State the partial's purpose.
2. Define explicit locals or object input.
3. Keep domain and persistence decisions outside the partial.
4. Define empty and optional input behavior.
5. Use strict locals when the interface is stable and reused.
6. Update all callers together.
7. Add focused rendering tests.

## Failure modes

- hidden instance-variable dependency;
- undeclared locals;
- partial used for unrelated responsibilities;
- caller-specific conditionals leaking inward.

## Testing

Test required locals, defaults, rendering output, and important caller variants.

## Review checklist

- [ ] interface explicit
- [ ] inputs minimal
- [ ] no hidden domain side effects
- [ ] callers compatible
- [ ] tests cover contract

## Related skills

- skills/rails-action-view/SKILL.md
- skills/rails-views/SKILL.md
- skills/ruby-clean-code/SKILL.md
