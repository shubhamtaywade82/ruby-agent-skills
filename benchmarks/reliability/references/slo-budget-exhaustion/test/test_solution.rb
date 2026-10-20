# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class SloBudgetExhaustionReferenceTest < Minitest::Test
  def test_reference_consumes_alerts_freezes_and_refills
    tracker = ErrorBudget.new(slo_target: 0.99, window_requests: 1000)

    tracker.record("server_error")
    tracker.record("timeout")
    assert_equal 8.5, tracker.remaining

    tracker.record("maintenance_note")
    assert_equal 8.5, tracker.remaining, "unclassified events consume nothing"

    4.times { tracker.record("server_error") }
    assert tracker.alert?

    5.times { tracker.record("server_error") }
    assert tracker.frozen?
    refute tracker.allowed?("feature_deploy")
    assert tracker.allowed?("security_patch")

    tracker.refill!
    assert_equal 10.0, tracker.remaining
    assert tracker.allowed?("feature_deploy")
    refute_nil tracker.events.find { |event| event.fetch("type") == "window_refilled" }
  end
end
