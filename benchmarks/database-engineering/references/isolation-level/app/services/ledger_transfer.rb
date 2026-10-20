# frozen_string_literal: true

# Ledger transfer under PostgreSQL transaction semantics.
#
# Isolation level: READ COMMITTED — the weakest level that preserves the
# transfer invariants here. Both affected rows are locked with
# SELECT ... FOR UPDATE in ascending id order before any balance is read or
# written, so every read-modify-write cycle serializes on the row locks
# themselves; a stronger snapshot level is unnecessary and a session-global
# override is never used (per-transaction SET LOCAL only).
#
# Retry handling: PG::SerializationFailure and PG::DeadlockDetected roll the
# transaction back on the server side, so the whole transfer is re-executed
# from a fresh BEGIN, bounded by MAX_ATTEMPTS. External effects (HTTP, mail,
# job enqueue) run only after commit, outside the locked section.
class LedgerTransfer
  ISOLATION_LEVEL = :read_committed
  MAX_ATTEMPTS = 3

  class InsufficientFunds < StandardError; end

  def self.call(db, from_id:, to_id:, amount:, externals: nil)
    attempts = 0
    begin
      attempts += 1
      db.begin_transaction
      db.set_local_isolation(ISOLATION_LEVEL)
      balances = [from_id, to_id].sort.each_with_object({}) do |id, memo|
        memo[id] = db.read_for_update(id)
      end
      raise InsufficientFunds, "account #{from_id} cannot cover #{amount}" if balances.fetch(from_id) < amount

      db.write(from_id, balances.fetch(from_id) - amount)
      db.write(to_id, balances.fetch(to_id) + amount)
      db.commit
    rescue PG::SerializationFailure, PG::DeadlockDetected
      raise if attempts >= MAX_ATTEMPTS

      retry
    rescue InsufficientFunds
      db.rollback
      raise
    end
    externals&.notify(
      "transfer.completed",
      { "from" => from_id, "to" => to_id, "amount" => amount }
    )
    { "from" => from_id, "to" => to_id, "amount" => amount, "attempts" => attempts }
  end
end
