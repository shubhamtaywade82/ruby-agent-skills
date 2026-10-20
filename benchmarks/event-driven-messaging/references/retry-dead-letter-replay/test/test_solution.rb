# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class ReferenceFlakyHandler
  attr_reader :calls, :applied

  def initialize
    @calls = 0
    @applied = []
    @failures_left = 1
  end

  def call(payload)
    @calls += 1
    if @failures_left.positive?
      @failures_left -= 1
      raise "transient failure"
    end

    @applied << payload.fetch("idempotency_key")
    nil
  end
end

class RetryDeadLetterReferenceTest < Minitest::Test
  def test_reference_retries_transient_failures_and_replays_safely
    handler = ReferenceFlakyHandler.new
    processor = MessageProcessor.new(
      handler: handler,
      retry_policy: RetryPolicy.new(max_attempts: 3),
      dead_letter_queue: DeadLetterQueue.new,
      clock: -> { 7 }
    )
    payload = { "idempotency_key" => "k-1", "event_type" => "order.placed", "data" => {} }

    result = processor.process(payload)
    replayed = processor.replay

    assert_equal "processed", result.fetch("status")
    assert_equal 2, result.fetch("attempts")
    assert_empty replayed
    assert_equal 1, handler.applied.length
  end
end
