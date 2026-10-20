# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Test-side scripted handler: ids listed in fail_ids always fail; every other
# message succeeds. Calls are recorded so scheduling behavior stays observable.
class ScriptedOutcomeHandler
  attr_reader :calls

  def initialize(fail_ids: [])
    @fail_ids = fail_ids
    @calls = []
  end

  def call(message)
    @calls << message.fetch("id")

    @fail_ids.include?(message.fetch("id")) ? :fail : :ok
  end
end

class OrderingConsumerCapacityTest < Minitest::Test
  def message_for(id, key)
    { "id" => id, "key" => key, "event_type" => "order.placed", "data" => {} }
  end

  def test_messages_sharing_a_key_complete_in_fifo_order
    group = OrderedConsumerGroup.new(handler: ScriptedOutcomeHandler.new, capacity: 2, buffer_limit: 10)
    %w[m1 m2 m3].each { |id| group.enqueue(message_for(id, "order-1")) }

    group.run

    assert_equal %w[m1 m2 m3], group.completions
  end

  def test_independent_keys_progress_in_parallel
    group = OrderedConsumerGroup.new(handler: ScriptedOutcomeHandler.new, capacity: 2, buffer_limit: 10)
    group.enqueue(message_for("a1", "key-a"))
    group.enqueue(message_for("b1", "key-b"))
    group.enqueue(message_for("a2", "key-a"))
    group.enqueue(message_for("b2", "key-b"))

    group.run

    assert_equal 2, group.in_flight_max, "two keys must be processed concurrently"
    assert_operator group.completions.index("a1"), :<, group.completions.index("a2")
    assert_operator group.completions.index("b1"), :<, group.completions.index("b2")
  end

  def test_capacity_bounds_in_flight_work
    bounded = OrderedConsumerGroup.new(handler: ScriptedOutcomeHandler.new, capacity: 2, buffer_limit: 10)
    bounded.enqueue(message_for("a1", "key-a"))
    bounded.enqueue(message_for("b1", "key-b"))
    bounded.enqueue(message_for("c1", "key-c"))
    bounded.run

    assert_equal 2, bounded.in_flight_max

    wider = OrderedConsumerGroup.new(handler: ScriptedOutcomeHandler.new, capacity: 3, buffer_limit: 10)
    wider.enqueue(message_for("a1", "key-a"))
    wider.enqueue(message_for("b1", "key-b"))
    wider.enqueue(message_for("c1", "key-c"))
    wider.run

    assert_equal 3, wider.in_flight_max
  end

  def test_buffer_limit_rejects_work_instead_of_queueing_unbounded
    group = OrderedConsumerGroup.new(handler: ScriptedOutcomeHandler.new, capacity: 2, buffer_limit: 2)

    assert_equal "accepted", group.enqueue(message_for("a1", "key-a")).fetch("status")
    assert_equal "accepted", group.enqueue(message_for("b1", "key-b")).fetch("status")

    rejected = group.enqueue(message_for("c1", "key-c"))

    assert_equal "rejected", rejected.fetch("status")
    assert_equal "buffer_full", rejected.fetch("reason")
  end

  def test_failing_head_retries_then_dead_letters_without_blocking_other_lanes
    group = OrderedConsumerGroup.new(
      handler: ScriptedOutcomeHandler.new(fail_ids: %w[a1]),
      capacity: 2,
      buffer_limit: 10,
      max_attempts: 2
    )
    group.enqueue(message_for("a1", "key-a"))
    group.enqueue(message_for("b1", "key-b"))
    group.enqueue(message_for("a2", "key-a"))

    group.run

    assert_equal %w[b1 a2], group.completions
    assert_equal 1, group.dead_letters.length

    dead = group.dead_letters.first

    assert_equal "a1", dead.fetch("message").fetch("id")
    assert_equal 2, dead.fetch("attempts")
    assert_equal "exhausted", dead.fetch("reason")
    assert_equal 2, group.in_flight_max, "the healthy lane keeps working while a1 retries"
  end
end
