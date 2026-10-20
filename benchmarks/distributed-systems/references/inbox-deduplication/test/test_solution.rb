# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class InboxDeduplicationReferenceTest < Minitest::Test
  def test_reference_processes_each_logical_message_exactly_once
    store = InboxStore.new
    ledger = OrdersLedger.new
    consumer = OrderConsumer.new(store: store, ledger: ledger, consumer_name: "orders")
    message = { "message_id" => "m-1", "event_type" => "order.created", "data" => { "order_id" => "o-1" } }

    first = consumer.consume(message)
    assert_equal "processed", first.fetch("status")
    assert_equal [:commit], store.journal.last

    duplicate = consumer.consume(message)

    assert_equal "duplicate", duplicate.fetch("status")
    assert_equal 1, ledger.applied.length
    assert_equal [:rollback], store.journal.last, "the duplicate delivery aborts its transaction"

    ledger.fail_next!
    crashed = consumer.consume("message_id" => "m-2", "event_type" => "order.created",
                               "data" => { "order_id" => "o-2" })

    assert_equal "failed", crashed.fetch("status")
    assert_equal [:rollback], store.journal.last
    assert_equal 1, ledger.applied.length
  end
end
