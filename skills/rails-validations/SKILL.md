---
name: rails-validations
description: Use when implementing or reviewing Rails model validations, validation contexts, error handling, or application/database invariants.
---

# Rails Validations

## Purpose

Express invalid application state clearly while separating user-facing validation from database-level integrity.

## Activate when

- adding/changing a model validation
- changing error messages
- using validation contexts
- debugging `valid?`/`save` behavior
- enforcing uniqueness or other cross-record invariants

## Repository inspection

Inspect:

- model
- schema
- migrations/constraints
- controller input boundary
- callbacks
- existing validation tests
- error serialization/presentation
- transactions if the rule spans multiple writes

## Decision rules

Use model validation when the rule is meaningful at the model/application boundary.

Do not put every input check in the model if the repository uses a distinct request/form/value boundary.

## Validation lifecycle

Understand when the validation executes and which operations can bypass it.

Investigate:

- `valid?`
- `save`
- `save!`
- `create`
- `update`
- validation contexts
- direct database operations
- callback ordering

Never assume all write paths execute the same validations.

## Uniqueness and concurrency

Application-level uniqueness validation improves errors but does not alone guarantee database uniqueness under concurrent writes.

When uniqueness is an invariant, inspect/add the appropriate database uniqueness constraint and test the application behavior around it.

## Errors

Keep error structure/messages compatible with the repository's user/API contract.

Do not change error shape accidentally during refactoring.

## Validation versus callback

Use validation for "is this state acceptable?"

Use callbacks only for lifecycle behavior that truly belongs to the model and is already consistent with repository conventions.

## Anti-patterns

- validation rules duplicated in many layers without reason
- assuming validation prevents all races
- callbacks used as hidden validation
- broad custom validation that mixes parsing, persistence, and presentation
- changing error contracts without updating callers/tests

## Agent review checklist

- [ ] validation belongs at this boundary
- [ ] all relevant write paths understood
- [ ] nil/empty/boundary inputs tested
- [ ] error contract preserved
- [ ] database constraint evaluated for critical invariants
- [ ] concurrency implications considered

## Verification

Test valid/invalid/boundary states and the specific persistence operations affected. For important database invariants, test both validation behavior and constraint behavior.

## Source foundation

Grounded in the validation material in *The Ruby Workshop*, with the behavior-first and test-oriented principles of *Clean Ruby*.
