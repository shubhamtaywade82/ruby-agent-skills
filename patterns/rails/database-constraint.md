---
name: database-constraint
description: Enforce a cross-writer data invariant at the database boundary.
family: rails
---

# Database Constraint

## Problem
Application validations alone can race when multiple writers modify the same data concurrently.

## Use when
An invariant must hold regardless of which process or application path writes the database.

## Do not use when
The rule is contextual presentation logic that cannot be represented as a durable database invariant.

## Implementation procedure
1. State the invariant precisely.
2. Add application validation for useful error feedback.
3. Add the corresponding unique, foreign-key, check, or NOT NULL database constraint.
4. Audit existing data before enabling the constraint.
5. Handle database constraint violations at the application boundary.
6. Test duplicate/concurrent writes where relevant.

## Failure modes
- relying on model uniqueness validation alone
- adding a constraint before cleaning violating rows
- swallowing constraint violations as generic success

## Testing
Test valid application behavior and direct database rejection of invalid state.

## Review checklist
- invariant is explicit
- DB constraint is authoritative
- existing data is clean
- violation behavior is understood


## Repository inspection

Inspect runtime/version, repository conventions, the owning boundary, neighboring implementations, and applicable tests before applying the pattern.


## Related skills

- rails-testing
- ruby-tdd-refactoring
- rails-architecture
