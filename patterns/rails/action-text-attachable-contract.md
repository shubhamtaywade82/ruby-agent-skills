---
name: action-text-attachable-contract
description: Define safe Rails Action Text attachable types, Signed Global ID usage, rendering partials, and missing-record behavior.
family: rails
---

# Action Text Attachable Contract

## Problem

Arbitrary attachables can turn Signed Global IDs and rendering partials into an object-disclosure boundary.

## Use when

- implementing custom ActionText::Attachable models;
- changing embedded object types or partials.

## Do not use when

- only standard Active Storage attachments are embedded.

## Repository inspection

Inspect attachable model modules, SGID configuration, partial paths, allowed types, tenant ownership, and deletion behavior.

## Implementation procedure

1. Explicitly allow attachable types.
2. Define SGID purpose/lifetime.
3. Verify editor/reference authorization.
4. Define rendering partial.
5. Define missing-object fallback.
6. Review sensitive fields and tenant isolation.
7. Test authorized and missing references.

## Failure modes

- any model becomes attachable;
- SGID treated as authorization;
- privileged object partial exposed;
- deleted object breaks rendering.

## Testing

Test allowed/disallowed types, authorized references, cross-tenant references, and missing records.

## Review checklist

- [ ] allowed type set
- [ ] SGID semantics
- [ ] authorization
- [ ] partial contract
- [ ] fallback
- [ ] tests

## Related skills

rails-action-text, rails-security, rails-security-engineering
