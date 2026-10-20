# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class ConsumerIdempotencyReferenceTest < Minitest::Test
  def test_reference_consumes_once_and_acknowledges_after_commit
    store = DeduplicationStore.new
    handler = EffectsRecorder.new
    consumer = IdempotentConsumer.new(store: store, handler: handler)
    message = { "message_id" => "m-1", "event_type" => "order.placed", "data" => {} }

    first = consumer.consume(message)
    second = consumer.consume(message)

    assert_equal "processed", first.fetch("status")
    assert_equal "duplicate", second.fetch("status")
    assert_equal 1, handler.applied.length
    assert_includes consumer.journal, [:ack, "m-1"]
    assert_equal [:ack_duplicate, "m-1"], consumer.journal.last
  end
end
