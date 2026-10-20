# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class BulkheadSaturationTest < Minitest::Test
  def test_healthy_dependency_passes_through_without_rejections
    clock = Clock.new
    bulkhead = Bulkhead.new(capacity: 2, clock: clock)
    first = bulkhead.acquire
    second = bulkhead.acquire

    assert first.granted?
    assert second.granted?
    assert_equal 0, bulkhead.metrics.fetch("queue_depth")
    assert_equal 0, bulkhead.metrics.fetch("rejection_count")

    first.complete
    second.complete

    assert_equal 0, bulkhead.metrics.fetch("queue_depth")
    assert_equal 0, bulkhead.metrics.fetch("rejection_count")
    assert_equal 0.0, bulkhead.metrics.fetch("average_wait_seconds")
  end

  def test_over_capacity_call_is_rejected_fast_with_the_documented_fallback
    clock = Clock.new
    fallback = { "results" => "cached-set" }
    bulkhead = Bulkhead.new(capacity: 2, clock: clock, fallback: fallback)
    bulkhead.acquire
    bulkhead.acquire
    rejected = bulkhead.acquire

    refute rejected.granted?
    assert_equal fallback, rejected.fallback, "the caller receives the fallback, not an exception"
    assert_equal 1, bulkhead.metrics.fetch("rejection_count")
    assert_equal 0, bulkhead.metrics.fetch("queue_depth"), "the rejection is fast, not queued"
  end

  def test_metrics_expose_queue_depth_and_average_wait
    clock = Clock.new
    bulkhead = Bulkhead.new(capacity: 1, clock: clock, queue_capacity: 1)

    holder = bulkhead.acquire
    assert holder.granted?

    waiter = bulkhead.acquire
    assert waiter.queued?
    refute waiter.granted?
    assert_equal 1, bulkhead.metrics.fetch("queue_depth")

    rejected = bulkhead.acquire
    refute rejected.granted?
    refute rejected.queued?
    assert_equal 1, bulkhead.metrics.fetch("rejection_count")

    clock.advance(150)
    holder.complete

    assert waiter.granted?, "the queued request is admitted when a permit frees"
    assert_equal 0, bulkhead.metrics.fetch("queue_depth")
    assert_in_delta 0.15, bulkhead.metrics.fetch("average_wait_seconds"), 0.001

    waiter.complete
    assert_in_delta 0.15, bulkhead.metrics.fetch("average_wait_seconds"), 0.001
  end

  def test_saturated_bulkhead_does_not_block_a_different_dependency
    clock = Clock.new
    search = Bulkhead.new(capacity: 1, clock: clock, fallback: { "results" => [] })
    recommendations = Bulkhead.new(capacity: 1, clock: clock)

    saturated = search.acquire
    assert saturated.granted?
    rejected = search.acquire
    refute rejected.granted?

    isolated = recommendations.acquire

    assert isolated.granted?, "a different dependency must not be blocked by the saturated bulkhead"
  end

  def test_fallback_result_is_honored_across_repeated_saturation
    clock = Clock.new
    fallback = { "results" => [], "stale" => true }
    bulkhead = Bulkhead.new(capacity: 1, clock: clock, fallback: fallback)

    holder = bulkhead.acquire
    assert holder.granted?

    rejected = bulkhead.acquire
    refute rejected.granted?
    assert_equal fallback, rejected.fallback

    holder.complete
    admitted = bulkhead.acquire

    assert admitted.granted?, "capacity frees again after completion"
    assert_equal 1, bulkhead.metrics.fetch("rejection_count")
  end
end
