---
name: rails-views
description: Use when implementing or reviewing Rails views, ERB templates, forms, view helpers, rendering boundaries or presentation logic.
---

# Rails Views

## Purpose

Keep presentation understandable while preventing business logic from leaking into templates.

## Inspect first

Check neighboring views, partials, helpers, form conventions, response formats and system/request tests.

## Decision rules

- Keep views focused on presentation.
- Use partials when a repeated coherent presentation fragment exists.
- Use helpers or presenter-style boundaries when presentation logic becomes complex.
- Do not move domain rules into ERB just because a value is needed for display.
- Keep forms aligned with the controller/model contract and existing conventions.

## ERB

Prefer readable templates over dense inline Ruby.

When branching becomes difficult to read:
1. simplify the view condition
2. extract a presentation-specific helper/partial
3. keep domain behavior in the domain/application layer

## Forms

Verify:
- field names
- parameter nesting
- validation/error display
- submit behavior
- successful and failed render flows

## Verification

Use the repository's established view/system/request test style. Check both rendered content and important user interactions when covered by the project.

## Source foundation

Derived from the Action View, ERB, helper and form material in The Ruby Workshop.
