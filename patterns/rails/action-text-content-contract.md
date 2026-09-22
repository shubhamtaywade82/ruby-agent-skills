---
name: action-text-content-contract
description: Define the ownership, purpose, allowed rich-text features, size, visibility, and lifecycle contract for Rails Action Text content.
family: rails
---

# Action Text Content Contract

## Problem

Rich text becomes difficult to secure and evolve when the application does not define what the content represents and what embeds/features are allowed.

## Use when

- adding has_rich_text;
- changing rich-text fields;
- defining content limits or visibility.

## Do not use when

- the feature does not use Action Text.

## Repository inspection

Inspect owner model, tenant rules, forms/APIs, content consumers, attachment policy, retention, and tests.

## Implementation procedure

1. Identify owning resource.
2. Define content purpose.
3. Define formatting/embed contract.
4. Define visibility and retention.
5. Define size/attachment limits.
6. Define rendering/API representations.
7. Test lifecycle.

## Failure modes

- generic rich-text field with no ownership;
- arbitrary embeds;
- no size limits;
- private content rendered publicly;
- lifecycle unclear.

## Testing

Test association, visibility, permitted features, size limits, and lifecycle behavior.

## Review checklist

- [ ] owner
- [ ] purpose
- [ ] formatting/embed policy
- [ ] visibility
- [ ] size/limits
- [ ] lifecycle

## Related skills

rails-action-text, rails-activerecord, rails-views, rails-active-storage
