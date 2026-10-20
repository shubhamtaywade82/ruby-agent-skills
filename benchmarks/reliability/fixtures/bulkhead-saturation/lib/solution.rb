# frozen_string_literal: true

class Clock
  # Deterministic clock: now returns integer milliseconds and advance moves
  # time forward by the given milliseconds, so waits are simulated without
  # sleeping.
  attr_reader :now

  def initialize
    @now = 0
  end

  def advance(milliseconds)
    @now += milliseconds
    self
  end
end

class Bulkhead
  # Bounded concurrency for one slow dependency. acquire grants a permit
  # while capacity is free, enqueues while the admission queue has room,
  # and rejects fast otherwise (never queueing indefinitely). The returned
  # ticket answers granted?/queued?/fallback, and a granted ticket is
  # released by complete. metrics exposes "queue_depth", "rejection_count",
  # and "average_wait_seconds" for the waits of admitted requests.
  def initialize(capacity:, clock:, queue_capacity: 0, fallback: nil)
    nil
  end

  def acquire
    nil
  end

  def metrics
    nil
  end
end
