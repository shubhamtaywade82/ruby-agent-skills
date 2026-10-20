# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class BulkheadSaturationReferenceTest < Minitest::Test
  def test_reference_grants_rejects_and_measures_admission_waits
    clock = Clock.new
    bulkhead = Bulkhead.new(capacity: 1, clock: clock, queue_capacity: 1, fallback: { "results" => [] })

    holder = bulkhead.acquire
    waiter = bulkhead.acquire
    rejected = bulkhead.acquire

    assert holder.granted?
    assert waiter.queued?
    refute rejected.granted?
    assert_equal 1, bulkhead.metrics.fetch("rejection_count")

    clock.advance(150)
    holder.complete

    assert waiter.granted?
    assert_in_delta 0.15, bulkhead.metrics.fetch("average_wait_seconds"), 0.001
  end
end
