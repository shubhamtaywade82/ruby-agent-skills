# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class LoadShedThresholdTest < Minitest::Test
  def gate(shed_above: 0.8, recover_below: 0.5, retry_after_seconds: 30)
    LoadShedder.new(shed_above: shed_above, recover_below: recover_below,
                    retry_after_seconds: retry_after_seconds)
  end

  def test_signal_below_the_threshold_passes_through
    shedder = gate
    shedder.observe(0.4)
    decision = shedder.check

    assert decision.fetch("allowed")
    assert_equal 200, decision.fetch("status")
    assert_empty shedder.events
  end

  def test_signal_crossing_the_threshold_sheds_subsequent_requests
    shedder = gate
    shedder.observe(0.85)
    decision = shedder.check

    refute decision.fetch("allowed")
    assert_equal 503, decision.fetch("status")
    assert_equal 30, decision.fetch("retry_after")
    assert_equal 0.85, decision.fetch("signal")
    assert_equal 0.8, decision.fetch("threshold")
  end

  def test_every_shed_decision_emits_an_observable_event
    shedder = gate
    shedder.observe(0.85)

    shedder.check
    shedder.check

    engaged = shedder.events.find { |event| event.fetch("type") == "shed_engaged" }
    refute_nil engaged
    assert_equal 0.85, engaged.fetch("signal")
    assert_equal 0.8, engaged.fetch("threshold")
    sheds = shedder.events.select { |event| event.fetch("type") == "request_shed" }
    assert_equal 2, sheds.length, "every shed decision emits an event"
    assert_equal "load_shed", sheds.first.fetch("reason")
    assert_equal 0.85, sheds.first.fetch("signal")
  end

  def test_hysteresis_keeps_the_shed_on_between_the_bounds
    shedder = gate

    shedder.observe(0.85)
    refute shedder.check.fetch("allowed")

    shedder.observe(0.7)
    refute shedder.check.fetch("allowed"), "between the bounds the shed stays on"

    shedder.observe(0.75)
    refute shedder.check.fetch("allowed")

    shedder.observe(0.49)
    assert shedder.check.fetch("allowed"), "only below the lower bound clears the shed"

    shedder.observe(0.6)
    assert shedder.check.fetch("allowed"), "recovery below shed_above does not re-engage"

    shedder.observe(0.81)
    refute shedder.check.fetch("allowed"), "crossing the upper bound re-engages the shed"

    assert_equal 2, shedder.events.count { |event| event.fetch("type") == "shed_engaged" }
    assert_equal 1, shedder.events.count { |event| event.fetch("type") == "shed_released" }
  end

  def test_recovery_is_automatic_and_thresholds_are_configurable
    shedder = gate(shed_above: 0.9, recover_below: 0.7, retry_after_seconds: 10)

    shedder.observe(0.85)
    assert shedder.check.fetch("allowed"), "below the configured shed threshold"

    shedder.observe(0.92)
    refute shedder.check.fetch("allowed")
    assert_equal 10, shedder.check.fetch("retry_after")

    shedder.observe(0.65)
    assert shedder.check.fetch("allowed"), "recovery is automatic below the hysteresis bound"
  end
end
