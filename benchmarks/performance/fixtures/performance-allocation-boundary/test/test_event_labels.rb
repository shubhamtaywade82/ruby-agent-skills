# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/event_labels"

class EventLabelsTest < Minitest::Test
  def test_labels
    events = [{ label: "a" }, { label: "b" }]
    assert_equal %w[a b], EventLabels.labels(events)
  end
end
