# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class ReferenceOkHandler
  def call(_message)
    :ok
  end
end

class OrderingCapacityReferenceTest < Minitest::Test
  def test_reference_preserves_key_order_and_bounds_in_flight_work
    group = OrderedConsumerGroup.new(handler: ReferenceOkHandler.new, capacity: 2, buffer_limit: 10)

    assert_equal "accepted", group.enqueue({ "id" => "a1", "key" => "a" }).fetch("status")
    assert_equal "accepted", group.enqueue({ "id" => "a2", "key" => "a" }).fetch("status")
    assert_equal "accepted", group.enqueue({ "id" => "b1", "key" => "b" }).fetch("status")

    group.run

    assert_equal %w[a1 b1 a2], group.completions
    assert_equal 2, group.in_flight_max
  end
end
