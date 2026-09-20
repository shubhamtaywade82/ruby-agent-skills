---
name: rails-activerecord
description: Use for Rails models, migrations, ActiveRecord associations, validations, querying, persistence and database behavior.
---

# Rails ActiveRecord

## Before changing a model
Inspect schema, migrations, associations, validations, callbacks, scopes, dependent behavior, existing queries and tests.

Never infer database behavior from model code alone.

## Associations
Choose associations from actual domain relationships. Verify foreign keys, nullability, uniqueness and dependent semantics.

## Validations
Distinguish application validation from database constraints. For important invariants, evaluate whether a database constraint is also required.

Do not assume model validation alone prevents race-condition violations.

## Queries
Watch for N+1 queries, accidental large loads, Ruby-side filtering that belongs in SQL, missing indexes, ambiguous ordering and duplicate rows from joins.

Use scopes only when they remain readable and composable.

## Migrations
Make schema intent explicit. Prefer reversible migrations when practical. Consider production data volume, indexes and constraints.

## Verification
For persistence changes, verify migration behavior, model behavior, constraints/associations, query behavior and regression tests.

## Source foundation
Based on associations, validations, models, migrations and ORM material from The Ruby Workshop.