# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class OutboxAtomicityTest < Minitest::Test
  def setup
    @store = TransactionalStore.new
    @broker = MessageBroker.new
    @service = CheckoutService.new(store: @store)
    @relay = OutboxRelay.new(store: @store, broker: @broker)
  end

  def test_commit_persists_order_and_outbox_and_relay_publishes_exactly_once
    result = @service.place_order(order_id: "o-1", amount: 4200)

    assert_equal "placed", result.fetch("status")
    assert_equal 1, @store.orders.length
    entry = @store.outbox_entries.first
    refute entry.fetch("published"), "the relay, not the transaction, publishes"
    assert_equal "msg-o-1", entry.fetch("message_id")

    @relay.run

    assert_equal 1, @broker.messages.length
    assert @store.outbox_entries.first.fetch("published")
    assert_equal "msg-o-1", @broker.messages.first.fetch("message_id")
    assert_equal "o-1", @broker.messages.first.fetch("payload").fetch("order_id")
  end

  def test_rollback_persists_nothing_and_publishes_nothing
    @store.fail_next_order!
    result = @service.place_order(order_id: "o-2", amount: 100)

    assert_equal "failed", result.fetch("status")
    assert_empty @store.orders
    assert_empty @store.outbox_entries
    assert_equal [:rollback], @store.journal.last

    @relay.run

    assert_empty @broker.messages, "a rolled-back transaction must never publish"
  end

  def test_duplicate_relay_runs_are_a_no_op
    @service.place_order(order_id: "o-1", amount: 4200)

    @relay.run
    @relay.run

    assert_equal 1, @broker.messages.length, "the broker receives exactly one published message"
    assert @store.outbox_entries.first.fetch("published")
  end

  def test_relay_resumes_after_crash_and_the_broker_deduplicates
    @service.place_order(order_id: "o-1", amount: 4200)

    @relay.crash_after_publish = true
    assert_raises(OutboxRelayCrash) { @relay.run }

    assert_equal 1, @broker.messages.length, "the broker did receive the message before the crash"
    refute @store.outbox_entries.first.fetch("published"), "the row was not marked before the crash"

    @relay.crash_after_publish = false
    @relay.run

    assert_equal 1, @broker.messages.length, "the broker deduplicates on message id"
    assert @store.outbox_entries.first.fetch("published")
  end

  def test_outbox_row_is_written_in_the_same_transaction_as_the_order
    @service.place_order(order_id: "o-3", amount: 500)
    journal = @store.journal
    order_index = journal.index([:insert_order, "o-3"])
    outbox_index = journal.index([:insert_outbox, "msg-o-3"])
    commit_index = journal.index([:commit])

    refute_nil order_index
    refute_nil outbox_index
    refute_nil commit_index
    assert_operator order_index, :<, outbox_index, "the outbox row is written with the order"
    assert_operator outbox_index, :<, commit_index, "both rows commit together or not at all"
    assert_equal [:commit], journal.last
  end
end
