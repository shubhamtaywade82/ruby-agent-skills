# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class LoadShedThresholdReferenceTest < Minitest::Test
  def test_reference_sheds_with_hysteresis_and_recovers_automatically
    shedder = LoadShedder.new(shed_above: 0.8, recover_below: 0.5, retry_after_seconds: 30)

    shedder.observe(0.4)
    assert shedder.check.fetch("allowed")

    shedder.observe(0.85)
    decision = shedder.check
    refute decision.fetch("allowed")
    assert_equal 30, decision.fetch("retry_after")

    shedder.observe(0.7)
    refute shedder.check.fetch("allowed"), "hysteresis keeps the shed on between the bounds"

    shedder.observe(0.49)
    assert shedder.check.fetch("allowed")

    assert_equal 1, shedder.events.count { |event| event.fetch("type") == "shed_engaged" }
    assert_equal 1, shedder.events.count { |event| event.fetch("type") == "shed_released" }
    assert_equal 2, shedder.events.count { |event| event.fetch("type") == "request_shed" }
  end
end
