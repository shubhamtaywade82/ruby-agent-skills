# History, soft deletion, and denormalization

Reference for the `rails-data-modeling` skill. Load it on demand when modeling history, snapshots, soft deletion, derived values, or deliberate denormalization. The rule "denormalize only with an owner" stays in the skill's `SKILL.md`.

## Snapshots

A snapshot records what was true when something happened. It is a separate fact, not a duplicate:

```text
products.price_cents            # current price; changes over time
order_items.unit_price_cents    # price charged on this order; never changes
```

Snapshot any value a financial, legal, or audit record must reproduce later: prices, tax rates, addresses on shipped orders, plan terms on invoices. Never "normalize" these into a join to the current value.

## Temporal data

Ask first: does the application need only the current state, or must it reconstruct past states?

- **Current state only**: ordinary columns.
- **Effective-dated rows**: `effective_from` and `effective_to` (or a PostgreSQL range column), with an exclusion constraint so periods for the same subject cannot overlap. Current state is the row whose period contains now.
- **Append-only history**: an events or history table (`subscription_events`, `price_changes`) written on every change, never updated. Current state can be kept in a column for speed, but the history is the source of truth.

The answer changes the schema substantially, so settle it before the first migration.

## Soft deletion

Adding `deleted_at` is a modeling decision, not a column. Decide:

- Is the row truly deleted, or archived, cancelled, or deactivated? A specific state column is often clearer.
- Should dependent rows survive, be hidden, or be deleted?
- Should uniqueness ignore deleted rows? Then use a partial unique index:

  ```ruby
  add_index :users, :email, unique: true, where: "deleted_at IS NULL"
  ```

- Which queries exclude deleted rows, and how? A `default_scope` hides the rule and leaks into associations; explicit scopes are easier to audit.
- Can a row be restored, and what if a new row now holds its unique key?
- How long are deleted rows retained, and does privacy law require real deletion?

## Derived values

Do not store what can be derived from authoritative data, unless it is a snapshot or a measured need:

- `age` from `date_of_birth`: derive it.
- `order.total_cents` from line items: derive it, or store it as a snapshot when the issued total must never change, or cache it under the rules below.

## Controlled denormalization

Legitimate forms include counter caches, cached totals, summary tables, materialized views, search projections, and read models. Each one needs four answers, written down:

1. **Source**: which data is authoritative.
2. **Update path**: how the copy changes, and whether it updates in the same transaction or asynchronously.
3. **Repair**: how drift is detected and fixed (a reconciliation job, a rebuild task).
4. **Failure**: what readers see while the copy is stale, and whether that is acceptable.

Callbacks make denormalization look simple, but they miss bulk writes (`update_all`, `insert_all`, SQL) and other services. Prefer a single write path, a database-level mechanism, or a periodic rebuild when the value must be trustworthy.

Denormalize for a measured read cost or a stated requirement, never pre-emptively.
