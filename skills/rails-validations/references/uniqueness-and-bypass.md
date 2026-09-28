# Uniqueness, concurrent invariants, and validation bypass paths

Reference for the `rails-validations` skill. Load it on demand when a change validates uniqueness or concurrent invariants, or writes through paths that skip validation. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Uniqueness and concurrent invariants

Uniqueness validation is an application-level preflight check and can race under concurrent writes.

For authoritative uniqueness:

1. define the logical uniqueness key;
2. align application validation with normalized database values;
3. add or verify the database unique index/constraint;
4. decide how the application handles conflict errors;
5. test both friendly validation and authoritative conflict paths.

Scope, case sensitivity, collation, partial conditions, tenant keys, and normalization must agree across application and database semantics.

Do not normalize only inside validation when persistence identity depends on the normalized representation.

## Validation bypass paths

Audit direct/bulk writes whenever an invariant changes.

Examples include insert, insert_all, upsert, upsert_all, update_all, update_column, update_columns, touch, touch_all, counter-update methods, and save(validate: false).

The response is not to ban every bypass. Instead:

- identify the authoritative invariant;
- determine whether the writer is allowed to bypass application validation;
- move critical invariants to database constraints when necessary;
- document intentional exceptions;
- test the path independently.
