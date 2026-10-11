# Transaction Isolation and Locking

Reference for the `rails-database-engineering` skill. Load it on demand when a change sets a transaction isolation level, uses row or advisory locks, or diagnoses a deadlock, lock-wait, or serialization failure. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Isolation levels

PostgreSQL supports four SQL standard isolation levels, but only three are materially different. `READ UNCOMMITTED` is treated as `READ COMMITTED` in Postgres. The default is `READ COMMITTED`.

| Level | What it prevents | What it allows | Cost |
|---|---|---|---|
| `READ COMMITTED` (default) | dirty reads | non-repeatable reads, phantom reads, serialization anomalies | low |
| `REPEATABLE READ` | non-repeatable reads, phantom reads | serialization anomalies | medium |
| `SERIALIZABLE` | all anomalies (with retry) | none — strictest | high — may abort and require retry |

### Setting isolation in Rails

Rails 6+ supports `transaction(isolation: :serializable)`:

```ruby
ApplicationRecord.transaction(isolation: :serializable) do
  account = Account.lock("FOR UPDATE").find(account_id)
  account.update!(balance_cents: account.balance_cents + amount_cents)
end
```

Invariants — these are Postgres-specific and not enforced by Rails:

1. **The isolation level applies to all statements in the transaction**, including statements issued from jobs or services that share the connection. The connection-level isolation does not reset between transactions; the next transaction without an explicit isolation uses the default `READ COMMITTED`.

2. **Setting isolation on a connection pool** is not the same as setting it on a transaction. `database.yml` does not have an isolation-level key by design; per-transaction isolation is the correct granularity. Do not set isolation globally unless you are using a dedicated connection pool (e.g. a separate `ApplicationRecord::Serializable` base class with its own `connection_pool`) and you understand the cost.

3. **`SERIALIZABLE` aborts transactions** with `PG::SerializationFailure` (`SQLSTATE 40001`). The application must catch and retry. Active Record does not retry automatically. Use:

```ruby
class ConcurrentTransfer
  MAX_RETRIES = 3

  def self.call(from_id:, to_id:, amount_cents:)
    attempts = 0
    begin
      Account.transaction(isolation: :serializable) do
        from = Account.lock("FOR UPDATE").find(from_id)
        to = Account.lock("FOR UPDATE").find(to_id)
        raise InsufficientFunds if from.balance_cents < amount_cents

        from.update!(balance_cents: from.balance_cents - amount_cents)
        to.update!(balance_cents: to.balance_cents + amount_cents)
      end
    rescue ActiveRecord::StatementInvalid => e
      raise unless e.cause.is_a?(PG::SerializationFailure)
      attempts += 1
      raise if attempts >= MAX_RETRIES
      sleep((2 ** attempts) * 0.05)  # small backoff for in-process retry
      retry
    end
  end
end
```

`SERIALIZABLE` retry is not free. Measure the abort rate before adopting `:serializable` for a hot path — if more than 1% of transactions abort, the throughput cost is usually higher than the engineering cost of using `REPEATABLE READ` + explicit locks.

### When to use which level

- `READ COMMITTED` — the default. Use for the vast majority of write transactions, including those that touch a small number of rows with `FOR UPDATE`.
- `REPEATABLE READ` — use when a transaction reads the same row twice and must see the same value (e.g. read-modify-write across two queries with a calculation in between). Postgres' `REPEATABLE READ` is stronger than the SQL standard — it prevents phantom reads as well.
- `SERIALIZABLE` — use when concurrent transactions must produce the same result as if they had run serially, and explicit locks are impractical. Pay the abort cost. Examples: ledger transfers, inventory reservation with cross-row invariants, multi-row uniqueness checks.

## Row locks (`SELECT ... FOR UPDATE`)

PostgreSQL row locks prevent concurrent modification of selected rows. They are not the same as isolation levels: `FOR UPDATE` is per-row; isolation levels are per-transaction.

### Variants

| Lock | What it blocks | Use when |
|---|---|---|
| `FOR UPDATE` | `UPDATE`, `DELETE`, `SELECT ... FOR UPDATE` (same row) | you will update the row in the same transaction |
| `FOR NO KEY UPDATE` | same as `FOR UPDATE` but does not block locks on key columns | stronger than needed; smaller lock footprint |
| `FOR SHARE` | `UPDATE`, `DELETE` (not other `SELECT FOR SHARE`) | read-lock without blocking reads |
| `FOR KEY SHARE` | `DELETE` and key-column `UPDATE` only | weak read-lock |

In Rails, `Account.lock("FOR UPDATE").find(id)` and `Account.lock("FOR NO KEY UPDATE").find(id)` are the standard forms. `with_lock` is shorthand for `transaction { lock("FOR UPDATE"); ... }`:

```ruby
account = Account.find(account_id)
account.with_lock do
  # SELECT ... FOR UPDATE issued here
  account.update!(balance_cents: account.balance_cents + amount_cents)
end
```

Invariants:

1. **Locks are released at transaction end.** `with_lock` wraps the block in a transaction; the lock is released when the block exits. Do not call out to a slow external service (HTTP, mail, job enqueue) inside `with_lock` — the lock is held for the duration.
2. **`SELECT ... FOR UPDATE` on an unlocked row is a no-op until the row is updated.** It does not prevent other transactions from reading; it only prevents them from acquiring the same lock or updating.
3. **`with_lock` reloads the row.** The lock is acquired after the SELECT, so the in-memory state may be stale by the time the lock is held. Re-read within the block if you need the locked value.

## Advisory locks

PostgreSQL advisory locks are application-level locks that live in Postgres but are not tied to a row. They are useful for coordinating across processes when a row lock does not fit (e.g. one-time maintenance, cron leader election, batch job coordination).

```ruby
# Transaction-scoped advisory lock (released on commit)
Account.transaction do
  ActiveRecord::Base.connection.execute("SELECT pg_advisory_xact_lock(42)")
  # do exclusive work
end

# Session-scoped advisory lock (released on connection close or explicit unlock)
ActiveRecord::Base.connection.execute("SELECT pg_advisory_lock(42)")
# do exclusive work
ActiveRecord::Base.connection.execute("SELECT pg_advisory_unlock(42)")
```

Two keyspaces: `pg_advisory_lock(int)` (single 64-bit integer) and `pg_advisory_lock(int, int)` (two 32-bit integers). They do not collide.

Invariants:

1. **Session locks leak** if a connection is returned to the pool without `pg_advisory_unlock`. Use the `with_advisory_lock` gem or wrap in a transaction (`pg_advisory_xact_lock`).
2. **Advisory locks do not prevent row modification.** They are advisory — the application must check `pg_try_advisory_lock` and back off if it fails. Postgres will not enforce the lock against direct `UPDATE` statements.
3. **Advisory locks are not durable across Postgres restarts.** They live in shared memory, not WAL.

## Optimistic vs pessimistic locking

Active Record supports both.

### Optimistic locking

```ruby
# db/migrate/20261011_add_lock_version_to_orders.rb
add_column :orders, :lock_version, :integer, default: 0, null: false

# app/models/order.rb
class Order < ApplicationRecord
  # optimistic locking is implicit once lock_version exists
end

# usage
order = Order.find(1)
order.update!(status: :paid)  # UPDATE ... WHERE lock_version = 1
# if another process updated it first, raises ActiveRecord::StaleObjectError
```

Use optimistic locking when:

- conflict is rare (most updates do not collide)
- you want to avoid `SELECT FOR UPDATE` lock overhead
- the application can recover from `StaleObjectError` by reloading and retrying

### Pessimistic locking

Use pessimistic locking (above) when:

- conflict is expected (high contention on a small set of rows)
- the cost of retry is higher than the cost of the lock
- you must serialize writes for correctness, not just for the version check

Do not mix the two on the same row. Choose one and document the choice in `AGENTS.md` or a decision record.

## Deadlock diagnosis

PostgreSQL detects deadlocks automatically and aborts one transaction with `PG::DeadlockDetected` (`SQLSTATE 40P01`). The aborted transaction sees:

```
ERROR:  deadlock detected
DETAIL:  Process 1234 waits for ShareLock on transaction 5678 held by process 5679.
Process 5679 waits for ShareLock on transaction 5678 held by process 1234.
HINT:  See server log for query details.
CONTEXT:  while updating tuple (...) in relation "..."
```

The Postgres server log includes the conflicting query. To diagnose from Rails:

```sql
SELECT pid, state, query, wait_event_type, wait_event, query_start
FROM pg_stat_activity
WHERE state != 'idle';
```

To find current locks:

```sql
SELECT pid, locktype, relation::regclass, mode, granted, transactionid
FROM pg_locks
WHERE NOT granted;
```

### Preventing deadlocks

1. **Consistent lock ordering.** Always lock parent rows before child rows, lower ids before higher ids, or follow a documented order. Inconsistent ordering is the most common cause of deadlocks.
2. **Short transactions.** The shorter the transaction, the smaller the window for a deadlock. Move HTTP calls, mail, and job enqueue out of the locked section (use `after_commit`).
3. **Lock only what you need.** `SELECT ... FOR UPDATE` on a large result set locks all rows. Lock a sentinel row or use `UPDATE ... WHERE` for the small set you actually need.
4. **Catch and retry `PG::DeadlockDetected`.** Active Record does not retry automatically. Use the same retry shape as `SERIALIZABLE` retry (above).

```ruby
rescue ActiveRecord::StatementInvalid => e
  raise unless e.cause.is_a?(PG::DeadlockDetected)
  attempts += 1
  raise if attempts >= MAX_RETRIES
  sleep((2 ** attempts) * 0.05)
  retry
end
```

5. **Set `lock_timeout` for hot tables.** `SET LOCAL lock_timeout = '2s'` aborts a transaction if a lock wait exceeds 2 seconds. Use this for hot-path transactions where waiting longer than 2 seconds is a worse outcome than failing fast.

## Connection-level configuration

Per-transaction configuration is the right granularity for most settings. For per-statement configuration (rare), use `SET LOCAL` inside a transaction:

```ruby
ApplicationRecord.transaction do
  ActiveRecord::Base.connection.execute("SET LOCAL statement_timeout = '5s'")
  # statement_timeout applies to the rest of this transaction
  do_work
end
```

`statement_timeout` and `lock_timeout` are the two most useful per-transaction settings. They are not connection-pool-level settings unless you have a dedicated pool for the workload.

## Source foundation

- PostgreSQL isolation levels: https://www.postgresql.org/docs/current/transaction-iso.html
- `SET TRANSACTION ISOLATION LEVEL`: https://www.postgresql.org/docs/current/sql-set-transaction.html
- Row-level locks (`FOR UPDATE` family): https://www.postgresql.org/docs/current/sql-select.html#SQL-FOR-UPDATE-SHARE
- Advisory locks: https://www.postgresql.org/docs/current/functions-admin.html#FUNCTIONS-ADVISORY-LOCKS
- `pg_locks` view: https://www.postgresql.org/docs/current/view-pg-locks.html
- `pg_stat_activity`: https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STAT-ACTIVITY-VIEW
- Active Record transactions: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html
- Active Record locking (optimistic + pessimistic): https://api.rubyonrails.org/classes/ActiveRecord/Locking.html

The `rails-database-engineering` skill owns the migration, constraint, and transaction boundary. This reference documents the isolation and locking primitives the skill activates on.
