# PostgreSQL Features

Reference for the `rails-database-engineering` skill. Load it on demand when a change uses PostgreSQL-specific features that Active Record does not abstract. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`. This reference covers `LISTEN/NOTIFY`, table partitioning, materialized views, `GIN`/`BRIN`/partial indexes, and stored procedures — Postgres features that Rails can use but does not own.

## LISTEN / NOTIFY

PostgreSQL's `LISTEN`/`NOTIFY` is a lightweight pub/sub channel that lives entirely inside Postgres. It does not require Redis, RabbitMQ, or Kafka. The cost is one extra Postgres connection per listener; the benefit is transactional coupling: a `NOTIFY` issued inside a transaction is only delivered after the transaction commits.

Use `LISTEN/NOTIFY` when:

- a Rails process needs to react to a committed database change without polling
- you want to avoid adding Redis for a small number of pub/sub channels
- the listener is in the same trust domain as the writer (it is not a cross-service boundary)

Do not use `LISTEN/NOTIFY` when:

- the consumer is a different service (use an outbox and `rails-event-driven-messaging` instead)
- throughput exceeds a few thousand notifications per second (use a real broker)
- the listener cannot tolerate missed notifications during a restart (Postgres drops `LISTEN` registrations on disconnect; there is no durable subscription)

```ruby
# Listener — typically a long-running `rake notifier:listen` task or a Sidekiq cron job
ActiveRecord::Base.connection.execute("LISTEN invoice_paid")

loop do
  ActiveRecord::Base.connection.raw_connection.wait_for_notify(1.0) do |channel, pid, payload|
    invoice_id = JSON.parse(payload).fetch("invoice_id")
    InvoicePaidBroadcaster.call(invoice_id)
  end
end
```

```ruby
# Publisher — issued from the invoice state machine after commit
class Invoice < ApplicationRecord
  after_commit :notify_paid, on: :update

  private

  def notify_paid
    return unless saved_change_to_status? && status == "paid"

    ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.sanitize_sql_array([
        "SELECT pg_notify('invoice_paid', ?)", { invoice_id: id }.to_json
      ])
    )
  end
end
```

Invariants:

- `NOTIFY` inside a transaction commits with it; `NOTIFY` outside a transaction fires immediately. Choose deliberately.
- Payloads are limited to 8000 bytes. Pass an id and fetch the record; do not pass the whole record as JSON.
- `LISTEN` registrations are per-connection. If your listener uses a connection pool, only one pool member receives each notification.
- Rails' `database.yml` `prepared_statements: true` interacts with `LISTEN`; verify with `pg_stat_activity` that the listener holds one connection.

`Solid Cable` (Rails 8's built-in Action Cable adapter) uses `LISTEN/NOTIFY` under the hood. Do not double-publish — if you are using `Solid Cable`, broadcast through Action Cable, not directly via `pg_notify`.

## Table partitioning

PostgreSQL supports declarative partitioning (since Postgres 10). Active Record 6.1+ supports partitioned tables as if they were ordinary tables, with caveats. Use partitioning when one table grows past the point where indexes and maintenance become expensive (rough rule of thumb: 50M+ rows or 50GB+).

### Range partitioning (most common — by time)

```ruby
# db/migrate/20261011_create_invoices.rb
def up
  execute <<~SQL
    CREATE TABLE invoices (
      id bigserial,
      account_id bigint NOT NULL,
      amount_cents integer NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now(),
      PRIMARY KEY (id, created_at)  -- partition key must be in the PK
    ) PARTITION BY RANGE (created_at);

    CREATE INDEX ON invoices (account_id, created_at);
  SQL
end
```

```ruby
# db/migrate/20261011_create_invoices_initial_partition.rb
def up
  execute <<~SQL
    CREATE TABLE invoices_2026_10
      PARTITION OF invoices
      FOR VALUES FROM ('2026-10-01') TO ('2026-11-01');
  SQL
end
```

Invariants:

- The partition key must be part of the primary key (or there must be no PK). This is a Postgres requirement, not an Active Record quirk.
- A row that does not match any partition raises `ERROR: no partition found`. Always have a default partition (`CREATE TABLE invoices_default PARTITION OF invoices DEFAULT`) or a future-month partition pre-created.
- Use `pg_partman` extension to automate partition creation. Register it in `data/database-engineering/tools.yml` if you adopt it.
- Active Record's `find_each` and `find_in_batches` work across partitions; `ORDER BY created_at` requires an index that includes the partition key.

### List and hash partitioning

List partitioning (by an enumerated value, e.g. tenant_id) and hash partitioning (by a hash of a key, for even distribution) are also supported. Use list partitioning when one tenant's volume dominates and others are small; use hash partitioning when distributing a uniform large table across N physical partitions for parallel scans.

### Cross-partition constraints

A `UNIQUE` constraint on a partitioned table must include all partition key columns. To enforce uniqueness on `(tenant_id, external_reference)` across all partitions when partitioning by `created_at`, you cannot use a unique index — instead, use a unique constraint on a per-partition basis plus an application-level check backed by a `SELECT ... FOR UPDATE` on a sentinel row.

## Materialized views

A materialized view is a query result persisted to disk and refreshable on demand. Use it when a read-heavy aggregation is too expensive to compute on every request.

```ruby
# db/migrate/20261011_create_account_balance_view.rb
def up
  execute <<~SQL
    CREATE MATERIALIZED VIEW account_balances AS
    SELECT
      accounts.id AS account_id,
      COALESCE(SUM(entries.amount_cents), 0) AS balance_cents,
      COUNT(entries.id) AS entry_count,
      MAX(entries.created_at) AS last_entry_at
    FROM accounts
    LEFT JOIN entries ON entries.account_id = accounts.id
    GROUP BY accounts.id;

    CREATE UNIQUE INDEX ON account_balances (account_id);
  SQL
end

def down
  execute "DROP MATERIALIZED VIEW account_balances"
end
```

Active Record integration:

```ruby
# app/models/account_balance.rb
class AccountBalance < ApplicationRecord
  self.table_name = "account_balances"
  belongs_to :account

  # Materialized views are read-only by default
  def readonly? = true
end
```

Refresh strategy:

- `REFRESH MATERIALIZED VIEW account_balances` — full rebuild, blocks reads
- `REFRESH MATERIALIZED VIEW CONCURRENTLY account_balances` — incremental, requires a unique index, does not block reads

Use `CONCURRENTLY` in production. Schedule the refresh with Sidekiq Cron or Solid Queue recurring tasks. Measure the refresh duration; if it exceeds the request timeout, refresh in a background job.

The `scenic` gem (registered in `data/database-engineering/tools.yml`) provides versioned materialized views with Rails migrations. Prefer `scenic` over hand-written `execute` when the view evolves.

## Indexes: GIN, BRIN, partial, expression

PostgreSQL supports index types Active Record's `add_index` helper does not surface by default. Use them deliberately.

### GIN (Generalized Inverted Index)

Use GIN for `jsonb`, `tsvector` (full-text search), and array columns.

```ruby
# db/migrate/20261011_add_tags_index.rb
def up
  execute "CREATE INDEX CONCURRENTLY index_products_on_tags ON products USING GIN (tags)"
end
```

For `jsonb` path queries:

```ruby
execute "CREATE INDEX CONCURRENTLY index_orders_on_metadata ON orders USING GIN (metadata jsonb_path_ops)"
```

`jsonb_path_ops` is smaller and faster than the default `jsonb_ops`, but supports only the `@>` containment operator. Use it when you only ever do `metadata @> { key: value }` queries.

### BRIN (Block Range Index)

Use BRIN for naturally ordered, very large tables (logs, time-series) where adjacent blocks share similar values. BRIN indexes are tiny (kilobytes, not gigabytes) and almost free to maintain.

```ruby
execute "CREATE INDEX index_event_logs_on_created_at ON event_logs USING BRIN (created_at)"
```

BRIN is not appropriate for `WHERE created_at > ?` queries on small tables — use B-tree there. BRIN shines on append-only, time-ordered, multi-million-row tables.

### Partial indexes

Index only the rows that match a `WHERE` predicate. Useful when one query pattern is hot and rare rows satisfy it.

```ruby
execute "CREATE INDEX CONCURRENTLY index_invoices_unpaid ON invoices (account_id) WHERE paid_at IS NULL"
```

Active Record's `add_index :invoices, :account_id, where: "paid_at IS NULL"` wraps this. The planner uses the partial index only for queries that match the predicate.

### Expression indexes

Index the result of a function or expression.

```ruby
execute "CREATE INDEX CONCURRENTLY index_users_on_lower_email ON users (lower(email))"
```

```ruby
add_index :users, "lower(email)", unique: true
```

Use for case-insensitive uniqueness, computed columns, or `LOWER(...)` lookups.

## Concurrent index creation

`CREATE INDEX CONCURRENTLY` does not take an `ACCESS EXCLUSIVE` lock and does not block writes. It is required for adding indexes to production tables. The migration must not be inside a transaction — Active Record wraps migrations in a transaction by default; disable with `disable_ddl_transaction!`:

```ruby
class AddOrdersIndex < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!
  def up
    execute "CREATE INDEX CONCURRENTLY index_orders_on_account_id ON orders (account_id)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_orders_on_account_id"
  end
end
```

`CONCURRENTLY` cannot run inside a transaction block. If it fails (e.g. a unique violation during build), it leaves an `INVALID` index — drop it and retry. Check `pg_index.indisvalid` after creation.

## Stored procedures and functions

Postgres functions (`CREATE FUNCTION`) run inside the database. Use them when:

- the operation needs to be atomic with constraints that Active Record cannot express
- a complex aggregation is hot enough that round-tripping rows to Ruby is the bottleneck
- a security boundary requires that the application only call a function, not read or write the underlying tables

```sql
CREATE OR REPLACE FUNCTION reserve_inventory(item_id bigint, quantity integer)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
  available integer;
BEGIN
  SELECT stock_count INTO available FROM inventory WHERE inventory.item_id = reserve_inventory.item_id FOR UPDATE;
  IF available < quantity THEN
    RETURN false;
  END IF;
  UPDATE inventory SET stock_count = stock_count - quantity WHERE inventory.item_id = reserve_inventory.item_id;
  RETURN true;
END;
$$;
```

```ruby
# app/models/inventory.rb
class Inventory < ApplicationRecord
  def self.reserve!(item_id:, quantity:)
    result = connection.select_value("SELECT reserve_inventory(#{item_id}, #{quantity})")
    ActiveRecord::Type::Boolean.new.deserialize(result)
  end
end
```

Prefer the `scenic` gem for versioned functions. Always parameterize the call — never interpolate user input into the function call SQL.

Stored procedures do not get you out of `rails-active-record` ownership for the underlying model. They are an optimization boundary; the model still owns the relation semantics and the invariants.

## `EXPLAIN` and query plans

Always check the query plan for a hot query. `EXPLAIN` shows the plan; `EXPLAIN ANALYZE` executes the query and shows actual timings.

```sql
EXPLAIN ANALYZE
SELECT * FROM invoices WHERE account_id = 42 ORDER BY created_at DESC LIMIT 10;
```

Invariants:

- `EXPLAIN ANALYZE` executes the query. Never run it against production for `DELETE`/`UPDATE` queries — use plain `EXPLAIN` for those.
- Look for `Seq Scan` (full table scan), `Hash Join` (memory-bound), and `Sort` (sort overhead).
- The planner needs up-to-date statistics. Run `ANALYZE invoices` after large inserts or deletes; `VACUUM` runs `ANALYZE` automatically.

Active Record logs the query plan when `config.active_record.debug_logs = true` and the query exceeds a threshold. Use this in development to spot N+1 before production.

## Source foundation

- PostgreSQL partitioning: https://www.postgresql.org/docs/current/ddl-partitioning.html
- Materialized views: https://www.postgresql.org/docs/current/sql-creatematerializedview.html
- Index types (B-tree, GIN, BRIN, GiST, SP-GiST): https://www.postgresql.org/docs/current/indexes-types.html
- `LISTEN`/`NOTIFY`: https://www.postgresql.org/docs/current/sql-listen.html
- `scenic` gem: https://github.com/scenic-views/scenic
- `pg_partman` extension: https://github.com/pgpartman/pg_partman
- Active Record `EXPLAIN`: https://guides.rubyonrails.org/active_record_querying.html#running-explain

These features are Postgres-specific. The `rails-database-engineering` skill owns the migration and constraint boundary; this reference documents what is available beyond the Active Record abstraction.
