# frozen_string_literal: true

require "minitest/autorun"

# PostgreSQL abort shapes the transfer must survive. The harness defines
# them (not the solution) exactly as the evaluation's retry contract names
# them, so rescuing these classes is part of the graded contract.
module PG
  class Error < StandardError; end
  class SerializationFailure < Error; end
  class DeadlockDetected < Error; end
end

# Deterministic single-threaded stand-in for a PostgreSQL session backing a
# ledger of accounts. It reproduces the semantics the transfer must respect:
#
# - writes require an open transaction and take the row lock implicitly,
#   exactly like an UPDATE statement;
# - read_for_update acquires the row lock up front (SELECT ... FOR UPDATE)
#   and records the acquisition order per transaction;
# - set_local_isolation configures only the current transaction (SET LOCAL);
#   set_isolation mutates the session globally, which the contract forbids;
# - commit-time serialization aborts and lock-time deadlock aborts roll the
#   transaction back automatically before raising, like the server does;
# - an armed concurrent transfer commits between a plain read and the write
#   that follows it, but defers until after commit when the rows it touches
#   are already locked, so stale unlocked reads lose updates while locked
#   read-modify-write cycles serialize on the row locks.
class LedgerDB
  MAX_TRANSACTIONS = 100

  class Error < StandardError; end
  class TransactionLimitExceeded < Error; end

  attr_reader :journal, :lock_orders, :global_isolation, :transactions_begun

  def initialize(balances = {})
    @balances = balances.dup
    @journal = []
    @lock_orders = []
    @armed = []
    @committed_armed = []
    @txn = nil
    @transactions_begun = 0
    @global_isolation = nil
    @fail_commit_once = nil
    @fail_commit_always = nil
    @fail_lock = {}
  end

  def balance(id)
    @balances.fetch(id)
  end

  def total
    @balances.values.sum
  end

  def transaction_open?
    !@txn.nil?
  end

  def locks_held
    @txn ? @txn[:locks].length : 0
  end

  def begin_transaction
    raise Error, "transaction already open" if @txn

    @transactions_begun += 1
    if @transactions_begun > MAX_TRANSACTIONS
      raise TransactionLimitExceeded, "more than #{MAX_TRANSACTIONS} transactions begun in one session"
    end

    @txn = { snapshot: @balances.dup, locks: [], overlay_start: @committed_armed.length }
    @lock_orders << []
    @journal << [:begin]
  end

  def set_local_isolation(level)
    ensure_transaction!
    @txn[:isolation] = level
    @journal << [:set_local_isolation, level]
  end

  def set_isolation(level)
    @global_isolation = level
    @journal << [:set_isolation, level]
  end

  def read(id)
    value = @balances.fetch(id)
    @journal << [:read, id, value]
    fire_armed_for(id, locked: false)
    value
  end

  def read_for_update(id)
    ensure_transaction!
    if @fail_lock.key?(id)
      error = @fail_lock.delete(id)
      abort_transaction!(error)
    end
    lock_row(id)
    value = @balances.fetch(id)
    @journal << [:read_for_update, id, value]
    fire_armed_for(id, locked: true)
    value
  end

  def write(id, new_balance)
    ensure_transaction!
    lock_row(id)
    @balances[id] = new_balance
    @journal << [:write, id, new_balance]
  end

  def commit
    ensure_transaction!
    error = @fail_commit_once || @fail_commit_always
    @fail_commit_once = nil
    abort_transaction!(error) if error

    deferred = @armed.select { |transfer| transfer[:state] == :deferred }
    @txn = nil
    @journal << [:commit]
    deferred.each do |transfer|
      transfer[:state] = :applied
      commit_armed(transfer)
    end
  end

  def rollback
    return unless @txn

    restore_snapshot
    @txn = nil
    @journal << [:rollback]
  end

  def arm_concurrent_transfer(from_id:, to_id:, amount:)
    @armed << { from_id: from_id, to_id: to_id, amount: amount, state: :pending }
  end

  def fail_next_commit_with(error)
    @fail_commit_once = error
  end

  def fail_commits_always_with(error)
    @fail_commit_always = error
  end

  def fail_next_lock_on(row_id, error)
    @fail_lock[row_id] = error
  end

  private

  def ensure_transaction!
    raise Error, "no transaction open" unless @txn
  end

  def lock_row(id)
    return if @txn[:locks].include?(id)

    @txn[:locks] << id
    @lock_orders.last << id
    @journal << [:lock, id]
  end

  def fire_armed_for(id, locked:)
    @armed.each do |transfer|
      next unless transfer[:state] == :pending
      next unless [transfer[:from_id], transfer[:to_id]].include?(id)

      if locked
        transfer[:state] = :deferred
      else
        transfer[:state] = :applied
        commit_armed(transfer)
      end
    end
  end

  def commit_armed(transfer)
    apply_balances(transfer)
    @committed_armed << transfer
    @journal << [:concurrent_commit, transfer[:from_id], transfer[:to_id], transfer[:amount]]
  end

  def apply_balances(transfer)
    @balances[transfer[:from_id]] = @balances.fetch(transfer[:from_id]) - transfer[:amount]
    @balances[transfer[:to_id]] = @balances.fetch(transfer[:to_id]) + transfer[:amount]
  end

  def abort_transaction!(error_class)
    restore_snapshot
    @txn = nil
    @journal << [:abort, error_class.name]
    raise error_class, "simulated #{error_class} - transaction rolled back"
  end

  def restore_snapshot
    snapshot = @txn[:snapshot]
    overlay_start = @txn[:overlay_start]
    @balances = snapshot.dup
    @committed_armed[overlay_start..].each { |transfer| apply_balances(transfer) }
  end
end

# Test-side external-effects seam: HTTP, mail, and job enqueue all cross the
# transaction boundary through this spy, which records whether the call ran
# inside an open transaction and how many row locks were held at the time.
class RecordingExternals
  attr_reader :calls

  def initialize(db)
    @db = db
    @calls = []
  end

  def notify(event, payload)
    @calls << {
      "event" => event,
      "payload" => payload,
      "inside_transaction" => @db.transaction_open?,
      "locks_held" => @db.locks_held
    }
    nil
  end
end

require_relative "../app/services/ledger_transfer"

class IsolationLevelTest < Minitest::Test
  def setup
    @db = LedgerDB.new(1 => 100, 2 => 50)
    @externals = RecordingExternals.new(@db)
  end

  def test_concurrent_transfer_preserves_the_sum_invariant
    @db.arm_concurrent_transfer(from_id: 1, to_id: 2, amount: 25)

    result = LedgerTransfer.call(@db, from_id: 1, to_id: 2, amount: 30, externals: @externals)

    assert_equal 45, @db.balance(1), "both transfers must debit account 1 exactly once"
    assert_equal 105, @db.balance(2), "both transfers must credit account 2 exactly once"
    assert_equal 150, @db.total, "the sum of all balances must remain constant"
    assert_equal 1, @db.transactions_begun
    assert_equal [[1, 2]], @db.lock_orders
    assert_equal 1, @db.journal.count { |entry| entry.first == :concurrent_commit }
    assert_equal 1, result.fetch("attempts")
  end

  def test_serialization_abort_is_retried_once
    @db.fail_next_commit_with(PG::SerializationFailure)

    result = LedgerTransfer.call(@db, from_id: 1, to_id: 2, amount: 30, externals: @externals)

    assert_equal 2, result.fetch("attempts")
    assert_equal 2, @db.transactions_begun
    assert_equal 70, @db.balance(1)
    assert_equal 80, @db.balance(2)
    assert_equal 150, @db.total
    assert_equal 1, @externals.calls.length, "notification must fire exactly once despite the retry"
    refute @externals.calls.first.fetch("inside_transaction")
  end

  def test_deadlock_abort_is_retried_once
    @db.fail_next_lock_on(1, PG::DeadlockDetected)

    result = LedgerTransfer.call(@db, from_id: 1, to_id: 2, amount: 30, externals: @externals)

    assert_equal 2, result.fetch("attempts")
    assert_equal 2, @db.transactions_begun
    assert_equal 70, @db.balance(1)
    assert_equal 80, @db.balance(2)
    assert_equal 150, @db.total
    assert_equal 1, @externals.calls.length
  end

  def test_locks_are_acquired_in_ascending_id_order_regardless_of_argument_order
    db = LedgerDB.new(1 => 100, 99 => 50)

    LedgerTransfer.call(db, from_id: 99, to_id: 1, amount: 20, externals: RecordingExternals.new(db))

    assert_equal [[1, 99]], db.lock_orders
  end

  def test_insufficient_funds_fails_safely_without_applying
    assert_raises(LedgerTransfer::InsufficientFunds) do
      LedgerTransfer.call(@db, from_id: 1, to_id: 2, amount: 200, externals: @externals)
    end

    assert_equal 100, @db.balance(1)
    assert_equal 50, @db.balance(2)
    assert_equal 150, @db.total
    refute @db.transaction_open?, "a failed transfer must not leak an open transaction"
    assert_empty @externals.calls
  end

  def test_retries_are_bounded
    @db.fail_commits_always_with(PG::SerializationFailure)

    assert_raises(PG::SerializationFailure) do
      LedgerTransfer.call(@db, from_id: 1, to_id: 2, amount: 30)
    end

    assert_operator @db.transactions_begun, :>=, 2, "at least one retry must happen"
    assert_operator @db.transactions_begun, :<=, 6, "retrying must stay bounded"
    assert_equal 100, @db.balance(1)
    assert_equal 50, @db.balance(2)
  end

  def test_isolation_level_is_configured_per_transaction_not_globally
    LedgerTransfer.call(@db, from_id: 1, to_id: 2, amount: 30, externals: @externals)

    set_locals = @db.journal.select { |entry| entry.first == :set_local_isolation }
    # READ COMMITTED is the weakest level that preserves the invariants here:
    # both rows are locked with FOR UPDATE in ascending id order before any
    # balance is read, so read-modify-write cycles serialize on the row locks.
    assert_equal 1, set_locals.length
    assert_equal :read_committed, set_locals.first.fetch(1)
    assert_nil @db.global_isolation
    assert_empty @db.journal.select { |entry| entry.first == :set_isolation }
  end

  def test_external_effects_happen_only_outside_the_transaction
    LedgerTransfer.call(@db, from_id: 1, to_id: 2, amount: 30, externals: @externals)

    assert_equal 1, @externals.calls.length, "a completed transfer must notify exactly once"
    call = @externals.calls.first
    refute call.fetch("inside_transaction"), "HTTP/mail/enqueue must not run inside the locked transaction"
    assert_equal 0, call.fetch("locks_held")
  end
end
