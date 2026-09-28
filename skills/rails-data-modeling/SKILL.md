---
name: rails-data-modeling
description: Use when deciding what a Rails application's relational schema should represent before writing models or migrations, including entities versus values, keys, normalization, nullability, integrity constraints, type hierarchies, JSON columns, history, soft deletion, and deliberate denormalization.
---

# Rails Data Modeling

## Purpose

Decide what the database should represent before deciding how Rails maps it. Start from the business facts the system must record, not from "which model should I create". The relational model owns correctness; Active Record, associations, and migrations implement it.

```text
business facts
  -> entities and value concepts
  -> ownership and cardinality
  -> keys and functional dependencies
  -> normalized schema (3NF by default)
  -> constraints for every invariant
  -> Rails mapping (models, associations, types)
  -> read and write paths, then indexes
  -> denormalization only for a stated need
  -> history and evolution of existing data
```

## Activate when

- designing tables for a new feature or domain area
- a model is gaining columns that belong to a different concept, or a "god table" is growing
- choosing keys: bigint, UUID, composite, natural, or public identifiers
- choosing between STI, delegated types, polymorphic associations, separate tables, or composition
- deciding whether data belongs in a JSON/JSONB column or in relational columns and tables
- modeling history, snapshots, effective dates, soft deletion, or multi-tenant ownership
- adding a cached, derived, or duplicated value such as a total, counter, or summary
- reviewing a schema for update anomalies, missing constraints, or unclear `NULL` meaning
- mapping a legacy schema, or modernizing Rails guidance written for older Rails versions

## Boundary ownership

| Concern | Primary skill |
|---|---|
| What the schema represents: entities, keys, normalization, constraints to require, history, denormalization policy | rails-data-modeling |
| Association declarations, options, and dependent behavior | rails-associations |
| Migrations, indexes, constraint rollout, backfills, locking, and deploy safety | rails-database-engineering |
| Relation, query, and persistence-lifecycle semantics | rails-active-record |
| Ruby domain objects, aggregates, and invariants in code | ruby-domain-modeling |
| Validation errors and user feedback | rails-validations |
| Tenant access enforcement on every read and write path | rails-authorization |

This skill decides the target model and the constraints it needs; `rails-database-engineering` decides how to get an existing database there safely.

## Repository inspection

1. Resolve the Rails and database versions from `Gemfile.lock` and `config/database.yml`; several choices below depend on them.
2. Read `db/schema.rb` or `db/structure.sql`, existing constraints, indexes, and foreign keys.
3. Read the models touched: associations, validations, callbacks, enums, serialized and JSON attributes, and STI or delegated types.
4. Read the domain glossary and decision records (see `ruby-domain-modeling`).
5. Identify the real read and write paths: controllers, jobs, reports, imports, and external synchronization.
6. Estimate data volume and growth for tables being split, merged, or backfilled.
7. Check tenancy conventions: which column scopes data, and how uniqueness is scoped today.

Never infer database behavior from model code alone.

## Decision rules

1. **List the facts first.** For each fact, ask what determines it (its functional dependency) and who owns it. A fact is stored once, where its determinant lives.
2. **Separate entities from values.** Things with identity and a lifecycle (Order, Invoice, Membership) get tables. Values defined only by their content (Money, Address, DateRange) are columns owned by an entity, read through a value object, unless they need their own lifecycle or sharing.
3. **Normalize to 3NF by default.** Remove repeating groups (1NF), attributes that depend on only part of a composite key (2NF), and attributes that depend on another non-key attribute (3NF). Depart from it only by a recorded decision.
4. **Keep identity and uniqueness separate.** The primary key is persistence identity; business uniqueness (email, SKU, slug) is a unique constraint. Do not make a mutable business value the primary key.
5. **Give `NULL` one meaning.** For every nullable column, write down what absence means. When the column can hold "unknown", "not applicable", and "not yet", use an explicit state instead of `NULL`.
6. **Back every invariant with a constraint.** Required values get `NOT NULL`; relationships get foreign keys; business uniqueness gets a unique index scoped as the business rule is (often by tenant); value domains get check constraints. Validations add user feedback, not integrity.
7. **Choose hierarchies and flexible data deliberately.** STI, delegated types, polymorphic associations, and JSON columns each trade integrity or queryability for convenience. Use the decision tables in the reference, and record the choice.
8. **Preserve history on purpose.** A value that records what was true at a moment (the price on an order line) is a separate fact from the current value (the product's price), not a normalization error.
9. **Denormalize only with an owner.** Every cached, counted, or copied value names its authoritative source, how it is updated, how drift is detected and repaired, and what happens when the update fails.
10. **Treat existing data as part of the model.** A schema change is not done until existing rows satisfy the new model; plan the backfill and constraint rollout with `rails-database-engineering`.

## Critical invariants

- Model the business facts before choosing Rails models.
- Normalize for correctness first; denormalize only for a stated requirement or measured workload.
- A Rails association or validation is not an integrity guarantee; the database constraint is.
- A `has_one` needs a unique index on its foreign key, or the database allows many.
- Tenant-scoped business keys need a composite unique index that includes the tenant column.
- JSON columns never hold identifiers, statuses, or timestamps the application joins, filters, sorts, or constrains on.
- Never "normalize away" a historical snapshot.
- Never teach or generate removed Rails APIs; see the legacy reference for replacements.

## References

Load only the reference for the decision in front of you; each is one level deep. Consult a listed pattern only when the change needs its implementation shape.

| Load when | Reference | Covers | Patterns |
|---|---|---|---|
| identifying facts, dependencies, normal forms, or choosing keys | [references/normalization-and-keys.md](references/normalization-and-keys.md) | Functional dependencies; 1NF, 2NF, 3NF, BCNF; anomalies; primary key strategies; natural, surrogate, and public keys | `value-object` |
| relating tables, deciding nullability, or choosing constraints | [references/relationships-and-integrity.md](references/relationships-and-integrity.md) | Foreign key ownership; one-to-one; join models; `NULL` semantics; constraint matrix; multi-tenant keys | `bounded-context-contract` |
| choosing STI, delegated types, polymorphism, enums, JSON columns, or value-object mapping | [references/types-hierarchies-and-flexible-data.md](references/types-hierarchies-and-flexible-data.md) | Hierarchy decision table; enum options; JSON boundary; value-object mapping | `value-object` |
| modeling history, snapshots, soft deletion, derived values, or denormalization | [references/history-and-denormalization.md](references/history-and-denormalization.md) | Snapshots; temporal data; soft deletion; derived versus stored; controlled denormalization | none |
| mapping a legacy schema or modernizing older Rails guidance | [references/legacy-schemas-and-api-drift.md](references/legacy-schemas-and-api-drift.md) | Legacy mapping APIs; removed and replaced APIs; version-gated features | none |

## Reference example

A membership join entity with integrity in the database and a readable Rails mapping:

```ruby
class CreateProjectMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :project_memberships do |t|
      t.references :account, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: "member"
      t.timestamps
    end

    add_index :project_memberships, [:project_id, :user_id], unique: true
    add_check_constraint :project_memberships, "role IN ('owner', 'member', 'viewer')",
                         name: "project_memberships_role_valid"
  end
end

class ProjectMembership < ApplicationRecord
  belongs_to :account
  belongs_to :project
  belongs_to :user

  enum :role, { owner: "owner", member: "member", viewer: "viewer" }, validate: true
  validates :user_id, uniqueness: { scope: :project_id } # feedback; the index is the guarantee
end
```

The relationship has attributes (role, timestamps), so it is an entity, not a bare `has_and_belongs_to_many`. The unique index and check constraint hold under concurrent writes; the validation only produces a friendly error. `enum ... validate: true` requires Rails 7.1 or later.

## Agent review checklist

- [ ] Rails and database versions resolved; version-gated APIs checked
- [ ] facts listed with their determinants and owners
- [ ] entities and values separated; no table for a pure value without reason
- [ ] schema at 3NF, or each departure recorded
- [ ] primary key strategy chosen; business keys have unique constraints
- [ ] every nullable column has a stated meaning
- [ ] every invariant has a database constraint, with tenant scope where needed
- [ ] hierarchy, polymorphism, enum, and JSON choices justified
- [ ] historical snapshots preserved; derived values not stored without an owner
- [ ] each denormalized value has a source, update path, and repair path
- [ ] existing data, backfill, and constraint rollout planned with rails-database-engineering

## Failure modes

- starting from a model name instead of the facts the system records
- comma-separated or array columns holding independent facts that are filtered or joined
- copying a parent's attribute into child rows (a 2NF or 3NF violation) without a snapshot reason
- a mutable email, slug, or SKU as primary key
- `has_one` or `validates uniqueness` without the unique index
- nullable columns whose `NULL` means several things
- a JSON column holding the status or foreign key the application queries
- polymorphic associations used only to avoid creating a table, losing foreign keys
- STI across subclasses with mostly disjoint columns
- a stored total or count with no reconciliation path
- `deleted_at` added without deciding uniqueness, dependents, and default scoping
- guidance or generated code using removed APIs such as `update_attributes` or `find(:all, conditions: ...)`

## Verification

- Load the schema in a test database and prove each constraint rejects bad data: insert duplicates, orphans, `NULL`s, and out-of-domain values through SQL or `insert_all`, which skips validations and callbacks.
- Test the Rails mapping at the model and request level, including the validation error for each constrained rule.
- For denormalized values, test the update path and the repair job against a deliberately drifted row.
- For migrations on existing data, follow the verification in `rails-database-engineering`.

## Source foundation

- Rails guides: Active Record Basics, Associations, Migrations, Validations, and Active Record and PostgreSQL (https://guides.rubyonrails.org/). Resolve version-specific behavior against the application's Rails version.
- Relational theory: functional dependencies, normal forms (1NF through BCNF), and update anomalies as described by E. F. Codd and standard database texts.
- The durable Active Record concepts in *Pro Active Record: Databases with Ruby and Rails* (Apress, 2007): the object-relational mapping model, foreign-key ownership, transactions, locking, migrations as schema history, and legacy-schema mapping. Its API examples predate current Rails and are not used; the legacy reference lists their replacements.
