---
name: rails-validations
description: Use when implementing or reviewing Rails model validations, validation contexts, validation errors or database/application invariants.
---

# Rails Validations

## Purpose

Express application-level validity rules clearly and distinguish them from database guarantees.

## Inspect first

Read the model, schema, existing validations, callbacks, controller boundaries, error handling and tests.

## Decision rules

- Validate user/domain input at the model boundary when the rule belongs to the model.
- Keep validation messages consistent with the application's established behavior.
- Use validation contexts only when there is a real lifecycle distinction.
- Do not use callbacks to hide ordinary validation rules.
- Distinguish a model validation from a database constraint.

## Trigger and skip behavior

When changing validation behavior, explicitly understand:
- when validation runs
- which operations bypass it
- whether custom contexts are used
- how errors are surfaced

Never claim that a validation alone provides concurrency-safe uniqueness or other database-level guarantees.

## Database invariants

For critical invariants, evaluate the database constraint required to enforce correctness under concurrent writes.

## Verification

Test valid, invalid, boundary and bypass paths relevant to the rule.

Verify both application error behavior and database constraints when both are part of the contract.

## Source foundation

Derived from the validation material in The Ruby Workshop, with the behavior-first testing principles of Clean Ruby.
