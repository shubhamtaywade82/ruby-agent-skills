# Aggregates, access paths, and evolution

Reference for the `rails-data-modeling` skill. Load it on demand when deciding aggregate ownership, the Rails representation of a relational decision, indexes, write paths, counters and aggregates, or how the model evolves. Migration mechanics belong to `rails-database-engineering`; association options belong to `rails-associations`.

## Aggregate ownership

An aggregate is a cluster of records changed together under one invariant, with one **root** that controls every mutation. An `Order` with its `OrderItem`s is typical: "the order total matches its lines" and "a placed order's lines never change" are enforced by `Order`, not by callers editing items directly.

- Mutate children through the root (`order.add_item(...)`, `order.place!`), not `OrderItem.update(...)` from a controller.
- Children carry the root's foreign key with `NOT NULL` and are deleted with it: `has_many :order_items, dependent: :destroy`, or `on_delete: :cascade` when no callbacks are needed.
- Other aggregates reference the root by id only; they never reach into its children.
- Keep aggregates small. If two clusters change independently, they are separate aggregates linked by id.

Aggregate boundaries decide transaction scope and lock scope (`order.with_lock`), so they are data-model decisions, not only code organization.

## Rails mapping matrix

| Relational decision | Rails and database representation |
|---|---|
| one record owns many | foreign key on the child + `belongs_to` / `has_many` |
| many records relate to many | join model + `has_many :through` |
| exactly one child | foreign key + unique index + `has_one` |
| required parent | `belongs_to` (required by default) + foreign key + `NOT NULL` |
| business uniqueness | unique index (validation only for the message) |
| tenant-local uniqueness | composite unique index including the tenant column |
| flexible metadata | JSON/JSONB column, only when justified |
| independent lifecycle | its own table and model |
| value-only concept | owned columns + value object, or a custom attribute type |
| multiple concrete types | STI, delegated types, or separate tables, by the hierarchy table |
| shared target relationship | polymorphic association only when justified |
| historical fact | snapshot columns or a history table |
| derived current value | compute it; store it only with an owner |
| performance aggregate | counter cache, stored total, or summary table, with reconciliation |
| soft deletion | a state or timestamp column + partial unique indexes + explicit scopes |
| state machine | a string state column + Rails enum + check constraint |

## Query-driven index design

Normalization decides which facts exist; indexes decide how they are found. Derive every index from an access path:

```text
query: account.orders.where(status: "pending").order(created_at: :desc).limit(50)
index: add_index :orders, [:account_id, :status, :created_at]
```

- Put equality columns first (`account_id`, `status`), then the range or sort column (`created_at`).
- Index every foreign key used in joins or in `dependent:` deletes; `t.references` does this by default.
- Use partial indexes for queries on a subset (`where: "deleted_at IS NULL"`, `where: "status = 'pending'"`).
- Unique indexes are constraints first; they also serve lookups by the same columns.
- Do not index "important" columns speculatively. Each index costs every write. Confirm with query plans (`relation.explain`) and hand large-table index builds to `rails-database-engineering`, which owns concurrent creation.

## Write paths

A schema that reads well but cannot be written safely is still wrong. For each table, record:

- **who creates rows**: users, jobs, imports, or external synchronization;
- **what may change**: mutable columns versus immutable or append-only records (ledger entries, events, placed orders);
- **what is derived**: counters, totals, and projections, and what updates them;
- **contention**: rows many writers update at once (a shared counter, an account balance). Prefer append-only rows aggregated on read, or a periodic rollup, over a hot row;
- **bulk writers**: `insert_all`, `update_all`, and SQL skip callbacks and validations, so constraints must carry the rules.

## Counter caches and aggregates

| Mechanism | Fits | Watch for |
|---|---|---|
| `counter_cache: true` on `belongs_to` (column `<association>_count`) | per-parent counts read often | `update_all`, `delete_all`, and raw SQL skip it; repair with `reset_counters` |
| stored total on the parent | totals displayed or filtered often, or snapshots that must not change | the update path, locking, and a reconciliation query |
| summary table | dashboards over many parents or time buckets | rebuild strategy and freshness |
| materialized view (PostgreSQL, managed in `structure.sql` or a gem) | expensive read-only aggregates | refresh timing and locking during refresh |

Every mechanism needs the source, update path, repair path, and failure behavior written down (see the history and denormalization reference).

## Schema evolution

The data model changes while the application runs. Model the target, then stage the path with `rails-database-engineering`:

- **Split or move a fact**: expand (add the new table or column, write both), backfill, switch reads, contract (stop writing and drop the old form, with `ignored_columns` first).
- **Tighten integrity**: backfill or clean data before adding `NOT NULL`, unique indexes, foreign keys, or check constraints; add constraints in a form that does not lock large tables.
- **Change a hierarchy**: STI to delegated types or separate tables moves rows between tables; treat it as a data migration with verification queries.
- **Rename**: renaming a column or table breaks running code; use expand–contract, never a single rename on a live system.

A model change is not complete until the migration path from the current data is written and reviewed.
