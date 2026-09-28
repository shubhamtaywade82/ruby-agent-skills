# Types, hierarchies, and flexible data

Reference for the `rails-data-modeling` skill. Load it on demand when choosing single-table inheritance, delegated types, polymorphic associations, enums, JSON columns, or a value-object mapping. Check every API below against the application's Rails version.

## Hierarchies

| Option | Use when | Costs |
|---|---|---|
| **Single-table inheritance** (`type` column) | variants share identity, lifecycle, most columns, and queries | sparse columns for subclass-only data; every subclass shares one table's constraints |
| **Delegated types** (`delegated_type`, Rails 6.1+) | a common entity (`Entry`) with variants whose data differs substantially (`Message`, `Comment`) | two tables per variant read; more joins |
| **Separate tables** | variants share little and are queried separately | shared behavior lives in Ruby modules; cross-variant lists need `UNION` or a view |
| **Composition** | the "variant" is really a role or capability an entity has | more associations to reason about |

Choose STI only when most columns apply to every subclass; if subclasses need many columns the others leave `NULL`, move to delegated types or separate tables.

## Polymorphic associations

`belongs_to :attachable, polymorphic: true` stores `attachable_type` and `attachable_id`. The database cannot enforce a foreign key across several tables, so integrity moves into application code.

Use it when one concept genuinely attaches to several unrelated entity types (comments, attachments, audit events), not to avoid creating a table. Alternatives that keep foreign keys:

- one nullable foreign key per target plus a check constraint that exactly one is set;
- a join table per target (`invoice_comments`, `project_comments`);
- delegated types, when the targets are variants of one concept.

## Enums

Three different things share the name:

| Option | What it is | Notes |
|---|---|---|
| `ActiveRecord::Enum` | Rails mapping from symbols to stored values | declare as `enum :status, { pending: "pending", paid: "paid" }`; the keyword form `enum status: {...}` was removed in Rails 8.0. Prefer string values over integers for readability and safe reordering. |
| Check constraint | database guarantee of the value domain | pair with the Rails enum: `add_check_constraint :orders, "status IN ('pending', 'paid')"` |
| PostgreSQL enum type | a database type (`create_enum`, `t.enum ..., enum_type:`, Rails 7.0+) | adding values is easy; removing or renaming values needs a type migration |

A Rails enum alone does not stop other writers from storing unknown values; add a check constraint or a PostgreSQL enum type.

## JSON and JSONB columns

JSON is not a substitute for relational modeling.

Good candidates:

- payloads received from external providers, kept for audit or replay;
- configuration or metadata that varies by record and is rarely queried;
- sparse, schema-flexible attributes read as a whole.

Keep in relational columns anything the application:

- joins on or uses as a foreign key;
- filters or sorts by in common queries;
- constrains as unique or required;
- aggregates in reports.

If an attribute inside JSON starts being queried, promote it to a column (a stored generated column can help during the transition on databases that support it). Use `store_accessor` or a typed attribute for a small, known set of keys, and validate their shape in the model.

## Value objects

A value concept (Money, Address, DateRange) needs no table of its own unless it has identity or a lifecycle. Options, simplest first:

1. **Owned columns plus a PORO**: `amount_cents` and `currency` columns, with a method returning a `Money` value.
2. **Attribute API with a custom type** (`attribute :price, MoneyType.new`): when the value maps to one column and is used everywhere.
3. **`composed_of`**: still supported; maps several columns to one value object. Prefer options 1 or 2 for new code unless the repository already uses it.
4. **A separate table**: only when the value is shared, versioned, or has its own lifecycle, at which point it is an entity.
