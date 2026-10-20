# frozen_string_literal: true

require "minitest/autorun"

# Compact copy of the fixture's PostgreSQL session double: only the surface
# the reference test exercises (transactions, ordered row locks, per-
# transaction isolation, concurrent-transfer deferral, commit aborts).
module PG
  class Error < StandardError; end
  class SerializationFailure < Error; end
  class DeadlockDetected < Error; end
end

class ReferenceLedgerDB
  attr_reader :journal, :lock_orders, :transactions_begun

  def initialize(balances)
    @balances = balances.dup
    @journal = []
    @lock_orders = []
    @armed = []
    @committed_armed = []
    @txn = nil
    @transactions_begun = 0
    @fail_commit_once = nil
  end

  def balance(id)
    @balances.fetch(id)
  end

  def total
    @balances.values.sum
  end

  def begin_transaction
    @transactions_begun += 1
    @txn = { snapshot: @balances.dup, locks: [], overlay_start: @committed_armed.length }
    @lock_orders << []
    @journal << [:begin]
  end

  def set_local_isolation(level)
    @txn[:isolation] = level
    @journal << [:set_local_isolation, level]
  end

  def read_for_update(id)
    lock_row(id)
    value = @balances.fetch(id)
    @journal << [:read_for_update, id, value]
    @armed.each do |transfer|
      next unless transfer[:state] == :pending
      next unless [transfer[:from_id], transfer[:to_id]].include?(id)

      transfer[:state] = :deferred
    end
    value
  end

  def write(id, new_balance)
    lock_row(id)
    @balances[id] = new_balance
    @journal << [:write, id, new_balance]
  end

  def commit
    if @fail_commit_once
      error = @fail_commit_once
      @fail_commit_once = nil
      abort_transaction!(error)
    end

    deferred = @armed.select { |transfer| transfer[:state] == :deferred }
    @txn = nil
    @journal << [:commit]
    deferred.each do |transfer|
      transfer[:state] = :applied
      commit_armed(transfer)
    end
  end

  def arm_concurrent_transfer(from_id:, to_id:, amount:)
    @armed << { from_id: from_id, to_id: to_id, amount: amount, state: :pending }
  end

  def fail_next_commit_with(error)
    @fail_commit_once = error
  end

  private

  def lock_row(id)
    return if @txn[:locks].include?(id)

    @txn[:locks] << id
    @lock_orders.last << id
  end

  def commit_armed(transfer)
    apply_balances(transfer)
    @committed_armed << transfer
    @journal << [:concurrent_commit, transfer[:from_id], transfer[:to_id]]
  end

  def apply_balances(transfer)
    @balances[transfer[:from_id]] = @balances.fetch(transfer[:from_id]) - transfer[:amount]
    @balances[transfer[:to_id]] = @balances.fetch(transfer[:to_id]) + transfer[:amount]
  end

  def abort_transaction!(error_class)
    snapshot = @txn[:snapshot]
    overlay_start = @txn[:overlay_start]
    @txn = nil
    @balances = snapshot.dup
    @committed_armed[overlay_start..].each { |transfer| apply_balances(transfer) }
    @journal << [:abort, error_class.name]
    raise error_class, "simulated #{error_class}"
  end
end

require_relative "../app/services/ledger_transfer"

class LedgerTransferReferenceTest < Minitest::Test
  def test_reference_serializes_a_concurrent_transfer_behind_row_locks
    db = ReferenceLedgerDB.new(1 => 100, 2 => 50)
    db.arm_concurrent_transfer(from_id: 1, to_id: 2, amount: 25)

    result = LedgerTransfer.call(db, from_id: 1, to_id: 2, amount: 30, externals: nil)

    assert_equal 45, db.balance(1)
    assert_equal 105, db.balance(2)
    assert_equal 150, db.total
    assert_equal [[1, 2]], db.lock_orders
    assert_equal 1, db.journal.count { |entry| entry.first == :concurrent_commit }
    assert_equal 1, result.fetch("attempts")
  end

  def test_reference_retries_a_serialization_abort_exactly_once
    db = ReferenceLedgerDB.new(1 => 100, 2 => 50)
    db.fail_next_commit_with(PG::SerializationFailure)

    result = LedgerTransfer.call(db, from_id: 1, to_id: 2, amount: 30, externals: nil)

    assert_equal 2, db.transactions_begun
    assert_equal 2, result.fetch("attempts")
    assert_equal 70, db.balance(1)
    assert_equal 80, db.balance(2)
    assert_equal 150, db.total
  end
end
