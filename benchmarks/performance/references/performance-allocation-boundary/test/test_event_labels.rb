# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/event_labels"

class EventLabelsTest < Minitest::Test
  def test_labels
    events = [{ label: "a" }, { label: "b" }]
    assert_equal %w[a b], EventLabels.labels(events)
  end

  # Structural property: one pass over the input, so allocations do not grow
  # with an intermediate copy of the collection.
  def test_single_pass_allocations
    events = Array.new(10_000) { |i| { label: i.to_s } }
    EventLabels.labels(events)
    before = GC.stat(:total_allocated_objects)
    EventLabels.labels(events)
    allocated = GC.stat(:total_allocated_objects) - before

    assert_operator allocated, :<, 100
  end
end
