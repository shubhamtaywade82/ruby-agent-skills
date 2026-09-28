# Relationships and integrity

Reference for the `rails-data-modeling` skill. Load it on demand when relating tables, deciding nullability, or choosing constraints. Association options and dependent behavior belong to `rails-associations`; constraint rollout on existing data belongs to `rails-database-engineering`.

## Foreign key ownership decides the association

The table holding the foreign key is the `belongs_to` side. Ask:

- Which table owns the foreign key?
- What does `NULL` mean there? Can the child exist without the parent?
- What happens to children when the parent is removed?

```ruby
create_table :orders do |t|
  t.references :customer, null: false, foreign_key: true   # indexed by default
  t.timestamps
end

class Customer < ApplicationRecord
  has_many :orders
end

class Order < ApplicationRecord
  belongs_to :customer
end
```

A relationship is complete only with the foreign key column, its nullability, a database foreign key where integrity requires it, and an index.

## One-to-one

`has_one` does not stop a second child row. Enforce it:

```ruby
add_index :profiles, :user_id, unique: true
```

Put the foreign key on the side that can be absent or is created later.

## Many-to-many

Use an explicit join model (`has_many :through`) whenever the relationship has attributes (role, joined_at, invited_by) or its own lifecycle. The join row is then an entity. `has_and_belongs_to_many` fits only a bare pairing that will never gain attributes.

Enforce the pairing's uniqueness in the database:

```ruby
add_index :project_memberships, [:project_id, :user_id], unique: true
```

`validates :user_id, uniqueness: { scope: :project_id }` still races under concurrent inserts; keep it only for the error message.

## Nullability is domain meaning

For each nullable column, write down what `NULL` means. Warning signs:

- `status` nullable alongside explicit statuses: is `NULL` "pending", "unknown", or "legacy row"?
- `approved_at` nullable with no `approved_by`: approval state is split across columns.
- boolean columns allowing `NULL`: three states where two were intended.

Prefer `NOT NULL` with a default, or an explicit state value, unless absence is a genuine, single-meaning state.

## Constraint matrix

| Invariant | Rails (feedback) | Database (guarantee) |
|---|---|---|
| required value | `presence` validation | `NOT NULL` |
| valid parent | `belongs_to` (required by default) | foreign key |
| unique business key | `uniqueness` validation | unique index |
| tenant-local uniqueness | `uniqueness` with `scope: :account_id` | composite unique index including `account_id` |
| value range or domain | `numericality`, `inclusion` | check constraint (`add_check_constraint`, Rails 6.1+) |
| no overlapping ranges | custom validation | exclusion constraint (PostgreSQL; `add_exclusion_constraint`, Rails 7.1+) |
| exactly one of several columns set | custom validation | check constraint such as `num_nonnulls(a_id, b_id) = 1` (PostgreSQL) |

The database is the final integrity boundary; every write path that bypasses validations (`insert_all`, `update_columns`, SQL, other services) still meets it.

## Multi-tenant ownership

Make tenant ownership a column, not an inference:

```text
accounts
  ├── projects (account_id)
  ├── invoices (account_id)
  └── memberships (account_id)
```

- Put `account_id` on every tenant-owned table that is queried directly, even when it is derivable through a parent; direct scoping and composite constraints need it.
- Scope business uniqueness by tenant: `add_index :projects, [:account_id, :slug], unique: true`.
- Where the database supports it, a composite foreign key that includes `account_id` stops a child from pointing at another tenant's parent.
- Modeling ownership does not authorize access; every read and write path is still checked by `rails-authorization`.

## Splitting a god table

Split a wide table only when a column group has its own lifecycle, ownership, cardinality, privacy boundary, or write path, such as billing details, notification preferences, or onboarding state on `users`. Do not split merely to make the schema look layered; a one-to-one split adds a join to every read.
