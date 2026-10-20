# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class SloBudgetExhaustionTest < Minitest::Test
  def budget(slo_target: 0.99, window_requests: 1000)
    ErrorBudget.new(slo_target: slo_target, window_requests: window_requests)
  end

  def test_healthy_window_consumes_nothing_and_freezes_nothing
    tracker = budget

    assert_equal 10.0, tracker.remaining
    assert_equal 0.0, tracker.consumed_percent
    refute tracker.alert?
    refute tracker.frozen?
    assert tracker.allowed?("feature_deploy")
    assert_empty tracker.events
  end

  def test_bad_events_consume_budget_according_to_documented_severity
    tracker = budget

    tracker.record("server_error")
    tracker.record("server_error")
    tracker.record("timeout")

    assert_equal 7.5, tracker.remaining
    assert_equal 25.0, tracker.consumed_percent
    refute tracker.alert?
  end

  def test_unclassified_events_consume_nothing
    tracker = budget

    tracker.record("maintenance_note")

    assert_equal 10.0, tracker.remaining
    assert_equal 0.0, tracker.consumed_percent
    assert_empty tracker.events
  end

  def test_alert_fires_when_half_the_budget_is_consumed
    tracker = budget

    5.times { tracker.record("server_error") }

    assert tracker.alert?
    assert_equal 50.0, tracker.consumed_percent
    alert = tracker.events.find { |event| event.fetch("type") == "alert_raised" }
    refute_nil alert
    assert_equal 50.0, alert.fetch("consumed_percent")
    assert_equal 5.0, alert.fetch("remaining")

    tracker.record("server_error")

    assert_equal 1, tracker.events.count { |event| event.fetch("type") == "alert_raised" },
                 "the alert fires once per window, not once per event"
  end

  def test_freeze_blocks_non_essential_work_but_not_essential_work
    tracker = budget

    10.times { tracker.record("server_error") }

    assert tracker.frozen?
    refute tracker.allowed?("feature_deploy")
    refute tracker.allowed?("batch_job")
    assert tracker.allowed?("security_patch"), "essential work stays allowed during a freeze"
    assert tracker.allowed?("incident_response"), "incident response is essential"
    refute_nil tracker.events.find { |event| event.fetch("type") == "freeze_engaged" }
  end

  def test_refill_restores_the_budget_on_the_window_boundary
    tracker = budget
    10.times { tracker.record("server_error") }
    assert tracker.frozen?

    tracker.refill!

    assert_equal 10.0, tracker.remaining
    refute tracker.frozen?
    refute tracker.alert?
    assert tracker.allowed?("feature_deploy")
    refute_nil tracker.events.find { |event| event.fetch("type") == "window_refilled" }

    5.times { tracker.record("server_error") }

    assert tracker.alert?
    assert_equal 2, tracker.events.count { |event| event.fetch("type") == "alert_raised" },
                 "the alert can fire again in the new window"
  end
end
