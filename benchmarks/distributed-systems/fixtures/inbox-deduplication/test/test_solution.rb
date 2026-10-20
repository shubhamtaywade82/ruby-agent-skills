# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class InboxDeduplicationTest < Minitest::Test
  def setup
    @store = InboxStore.new
    @ledger = OrdersLedger.new
    @consumer = OrderConsumer.new(store: @store, ledger: @ledger, consumer_name: "orders")
    @message = { "message_id" => "m-0001", "event_type" => "order.created", "data" => { "order_id" => "o-1" } }
  end

  def test_first_delivery_processes_and_persists_the_inbox_row
    result = @consumer.consume(@message)

    assert_equal "processed", result.fetch("status")
    assert_equal 1, @ledger.applied.length
    assert_equal "m-0001", @ledger.applied.first.fetch("message_id")
    assert @store.include?("orders", "m-0001")
    assert_equal 1, @store.size
  end

  def test_redelivery_is_detected_as_a_duplicate_without_reapplying_effects
    @consumer.consume(@message)
    duplicate = @consumer.consume(@message)

    assert_equal "duplicate", duplicate.fetch("status")
    assert_equal 1, @ledger.applied.length, "the side effect must not be re-applied"
    assert_equal 1, @store.size, "the duplicate must not add a second inbox row"
  end

  def test_out_of_order_delivery_processes_each_logical_message_exactly_once
    out_of_order = [
      { "message_id" => "m-0002", "event_type" => "order.created", "data" => { "order_id" => "o-2" } },
      { "message_id" => "m-0001", "event_type" => "order.created", "data" => { "order_id" => "o-1" } }
    ]
    out_of_order.each { |message| @consumer.consume(message) }

    assert_equal 2, @ledger.applied.length
    assert_equal 2, @store.size

    out_of_order.each do |message|
      redelivered = @consumer.consume(message)

      assert_equal "duplicate", redelivered.fetch("status")
    end
    assert_equal 2, @ledger.applied.length

    envelope_a = { "message_id" => "m-0003", "event_type" => "order.created", "data" => { "order_id" => "o-3" } }
    envelope_b = { "message_id" => "m-0003", "event_type" => "order.created",
                   "data" => { "order_id" => "o-3", "note" => "broker redelivery" } }
    first = @consumer.consume(envelope_a)
    second = @consumer.consume(envelope_b)

    assert_equal "processed", first.fetch("status")
    assert_equal "duplicate", second.fetch("status")
    assert_equal 1, @ledger.applied.count { |entry| entry.fetch("order_id") == "o-3" },
                 "two deliveries of one logical message must apply the effect once"
  end

  def test_crash_between_inbox_and_effect_rolls_back_both_and_redelivery_reprocesses
    @ledger.fail_next!
    crashed = @consumer.consume(@message)

    assert_equal "failed", crashed.fetch("status")
    refute @store.include?("orders", "m-0001"), "the inbox row must roll back with the effect"
    assert_empty @ledger.applied, "the effect must not be visible after the crash"
    assert_equal [:rollback], @store.journal.last

    retried = @consumer.consume(@message)

    assert_equal "processed", retried.fetch("status")
    assert_equal 1, @ledger.applied.length
    assert @store.include?("orders", "m-0001")
  end

  def test_inbox_insert_and_effect_share_one_transaction
    @consumer.consume(@message)
    journal = @store.journal
    begin_index = journal.index([:begin])
    insert_index = journal.index([:insert, "orders", "m-0001"])
    commit_index = journal.index([:commit])

    refute_nil begin_index
    refute_nil insert_index
    refute_nil commit_index
    assert_operator begin_index, :<, insert_index, "the insert runs inside the transaction"
    assert_operator insert_index, :<, commit_index, "the insert commits only after the effect succeeds"
    assert_equal [:commit], journal.last, "a successful consume ends with the commit"
  end
end
