---
name: isolation-level-contract
description: "Choose and enforce the correct PostgreSQL transaction isolation level for a state transition; document the choice and the retry policy for SERIALIZABLE aborts."
family: rails
---

# Isolation Level Contract

## Problem
A multi-row state transition needs stronger guarantees than the default `READ COMMITTED` isolation level, but `SERIALIZABLE` is not free — it aborts transactions and requires application-level retry. The isolation level also persists for the entire transaction, including side effects issued after the lock is acquired.

## Use when
- a transaction must not see non-repeatable reads or phantom reads (use `REPEATABLE READ`)
- a transaction must produce the same result as if it ran serially, including across row sets that no single row lock can cover (use `SERIALIZABLE` with retry)
- a transactional write depends on a calculation across multiple rows that must remain consistent while the transaction runs (use `SERIALIZABLE` or explicit row locks on a sentinel)

## Do not use when
- the transaction touches a small number of rows that can be locked with `SELECT ... FOR UPDATE` — use a row lock instead
- the operation is read-only and does not require repeatable reads — use the default `READ COMMITTED`
- the throughput cost of `SERIALIZABLE` aborts has not been measured — measure first, adopt second

## Repository inspection
1. Resolve the database adapter and version (`database.yml`, `Gemfile.lock`).
2. Inspect existing `transaction(isolation: ...)` usage in `app/models/` and `app/services/`.
3. Inspect existing `with_lock`, `lock("FOR UPDATE")`, and `lock_version` usage.
4. Inspect existing retry handling for `PG::SerializationFailure` (`SQLSTATE 40001`) and `PG::DeadlockDetected` (`40P01`).
5. Inspect `database.yml` for any global isolation-level override (rare; usually incorrect).
6. Inspect `application_record.rb` and any base classes for connection pool configuration.
7. Inspect the Postgres server logs for `deadlock detected` and `could not serialize access due to` errors.

## Implementation procedure
1. State the invariant the transaction must preserve.
2. Identify the rows that own the state and the rows that must remain consistent.
3. Choose the weakest isolation level that preserves the invariant:
   - `READ COMMITTED` (default) — sufficient for the vast majority of writes
   - `REPEATABLE READ` — for read-modify-write across two queries in one transaction
   - `SERIALIZABLE` — for cross-row invariants that no single row lock covers
4. If using row locks, acquire them in a documented, consistent order (lowest id first, parent before child, or a per-table order).
5. Wrap the transaction body in a retry loop that catches `PG::SerializationFailure` and `PG::DeadlockDetected`.
6. Set a per-transaction `lock_timeout` for hot-path transactions where waiting longer than N seconds is worse than failing fast.
7. Document the isolation level choice and the retry policy in `AGENTS.md` or a decision record.
8. Add tests for the concurrency boundary: a `SERIALIZABLE` abort path and a retry that succeeds.

## Example

A ledger transfer between two accounts, where concurrent transfers must not produce inconsistent balances:

```ruby
class ConcurrentTransfer
  MAX_RETRIES = 3

  def self.call(from_id:, to_id:, amount_cents:)
    attempts = 0
    begin
      Account.transaction(isolation: :serializable) do
        # Lock both accounts in id order to avoid deadlocks
        accounts = Account.where(id: [from_id, to_id].sort).lock("FOR UPDATE").order(:id)
        from = accounts.find(from_id)
        to = accounts.find(to_id)

        raise InsufficientFunds if from.balance_cents < amount_cents

        from.update!(balance_cents: from.balance_cents - amount_cents)
        to.update!(balance_cents: to.balance_cents + amount_cents)
      end
    rescue ActiveRecord::StatementInvalid => e
      raise unless serialization_or_deadlock?(e.cause)
      attempts += 1
      raise if attempts >= MAX_RETRIES
      sleep((2 ** attempts) * 0.05)
      retry
    end
  end

  def self.serialization_or_deadlock?(cause)
    cause.is_a?(PG::SerializationFailure) || cause.is_a?(PG::DeadlockDetected)
  end
  private_class_method :serialization_or_deadlock?
end
```

Notes on the example:

- **`order(:id)` is load-bearing.** Without it, the lock order is non-deterministic across concurrent transfers, and deadlocks become common.
- **`MAX_RETRIES = 3` is the ceiling.** If the abort rate is high enough to hit it, the design is wrong — switch to `REPEATABLE READ` with explicit locks or refactor the contention.
- **`PG::SerializationFailure` and `PG::DeadlockDetected` are adapter-specific.** Wrap the check in a method so the transfer does not depend on `pg` gem internals at the call site.

## Failure modes
- Setting `:serializable` on a hot path without measuring the abort rate
- Mixing isolation levels on the same logical operation across services (one service uses `:serializable`, another uses default `:read_committed` on the same rows)
- Holding the `SELECT ... FOR UPDATE` lock across an HTTP call, mail send, or job enqueue
- Inconsistent lock ordering (parent before child in one code path, child before parent in another)
- Catching `PG::SerializationFailure` and retrying without backoff — thundering herd
- Setting isolation globally in `database.yml` instead of per-transaction
- Forgetting that `SET LOCAL` inside a transaction is scoped to the transaction, not the connection — settings leak to subsequent transactions on the same pooled connection if you use `SET` instead of `SET LOCAL`
- Treating `with_lock` as a serialization primitive when row contention is the wrong abstraction

## Testing
1. **Concurrency test**: spawn two `ConcurrentTransfer` calls in parallel threads (use `Thread` or `Concurrent::Promises`); assert that one succeeds and the other either succeeds or fails with `InsufficientFunds` or a serialization error.
2. **Abort injection**: stub `PG::SerializationFailure` on the first attempt and assert the retry succeeds.
3. **Lock ordering test**: with two accounts in reverse id order, verify the locks are still acquired in id order.
4. **Production evidence**: query `pg_stat_database` for `deadlocks` and `serial_failures` after running the workload under load.

## Review checklist
- [ ] Isolation level chosen and documented (weakest that preserves the invariant)
- [ ] Row locks acquired in a consistent, documented order
- [ ] Retry policy catches `PG::SerializationFailure` and `PG::DeadlockDetected`
- [ ] Retry has bounded attempts and backoff
- [ ] No HTTP, mail, or job enqueue inside the locked transaction section
- [ ] `SET LOCAL` used instead of `SET` for per-transaction configuration
- [ ] `lock_timeout` set for hot-path transactions
- [ ] Tests cover the abort path and the retry success
- [ ] No global isolation-level override in `database.yml`

## Related skills
rails-database-engineering, ruby-concurrency, rails-active-record, rails-active-job
