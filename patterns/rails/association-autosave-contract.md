---
name: association-autosave-contract
description: Use when changing how associated records are built, validated, and persisted with a parent record.
family: rails
---

# Association Autosave Contract

## Problem

Associated records can be built, saved, validated, or rolled back according to association and autosave semantics that are easy to misread.

## Use when

- changing autosave
- adding nested attributes
- building records through an association
- debugging partial association persistence.

## Do not use when

- the change is only read-only association traversal.

## Repository inspection

Inspect parent/child associations, validation, autosave settings, transactions, inverse relationships, and nested attributes.

## Implementation procedure

1. Identify which new and existing child changes should persist with the parent.
2. Determine validation and rollback behavior.
3. Verify inverse association requirements.
4. Define transaction ownership.
5. Test parent success/failure and child failure.

## Failure modes

- assuming parent save persists every child
- partial persistence due to misunderstood transaction ownership
- enabling autosave to mask an unclear workflow.

## Testing

Test new child, changed existing child, invalid child, parent failure, and rollback behavior.

## Review checklist

- [ ] persistence ownership is explicit
- [ ] validations are understood
- [ ] transaction boundary is clear
- [ ] failure paths are tested

## Related skills

rails-associations, rails-active-record, rails-validations
