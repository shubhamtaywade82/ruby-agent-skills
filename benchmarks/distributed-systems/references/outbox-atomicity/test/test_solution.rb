# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class OutboxAtomicityReferenceTest < Minitest::Test
  def test_reference_publishes_after_commit_and_survives_a_relay_crash
    store = TransactionalStore.new
    broker = MessageBroker.new
    service = CheckoutService.new(store: store)
    relay = OutboxRelay.new(store: store, broker: broker)

    placed = service.place_order(order_id: "o-1", amount: 4200)

    assert_equal "placed", placed.fetch("status")

    relay.crash_after_publish = true
    assert_raises(OutboxRelayCrash) { relay.run }

    relay.crash_after_publish = false
    relay.run
    relay.run

    assert_equal 1, broker.messages.length
    assert store.outbox_entries.first.fetch("published")

    store.fail_next_order!
    failed = service.place_order(order_id: "o-2", amount: 100)

    assert_equal "failed", failed.fetch("status")
    assert_equal 1, broker.messages.length
  end
end
