# frozen_string_literal: true

# Bulkhead isolation with deterministic semantics: capacity permits are
# granted immediately, overflow waits in a bounded admission queue that
# drains as permits free, and anything beyond both bounds is rejected fast
# with the documented fallback. Waits are measured with the injected clock,
# so no threads or sleeps are needed and metrics stay reproducible.
class Clock
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
  class Ticket
    attr_reader :state, :fallback, :requested_at, :wait_seconds

    def initialize(bulkhead:, state:, fallback: nil)
      @bulkhead = bulkhead
      @state = state
      @fallback = fallback
      @requested_at = bulkhead.clock.now
      @wait_seconds = nil
    end

    def granted?
      @state == :granted
    end

    def queued?
      @state == :queued
    end

    def complete
      @bulkhead.release(self)
      @state = :completed
      nil
    end

    def grant(wait_seconds)
      @wait_seconds = wait_seconds
      @state = :granted
      nil
    end
  end

  attr_reader :clock

  def initialize(capacity:, clock:, queue_capacity: 0, fallback: nil)
    @capacity = capacity
    @clock = clock
    @queue_capacity = queue_capacity
    @fallback = fallback
    @in_use = 0
    @queue = []
    @rejection_count = 0
    @admitted_waits = []
  end

  def acquire
    if @in_use < @capacity
      @in_use += 1
      return Ticket.new(bulkhead: self, state: :granted)
    end

    if @queue.length < @queue_capacity
      ticket = Ticket.new(bulkhead: self, state: :queued)
      @queue << ticket
      return ticket
    end

    @rejection_count += 1
    Ticket.new(bulkhead: self, state: :rejected, fallback: @fallback)
  end

  def metrics
    {
      "queue_depth" => @queue.length,
      "rejection_count" => @rejection_count,
      "average_wait_seconds" => admitted_average_wait
    }
  end

  def release(_ticket)
    @in_use -= 1
    drain_queue
    nil
  end

  private

  def admitted_average_wait
    return 0.0 if @admitted_waits.empty?

    @admitted_waits.sum / @admitted_waits.length
  end

  def drain_queue
    while @in_use < @capacity && !@queue.empty?
      ticket = @queue.shift
      @in_use += 1
      wait_seconds = (@clock.now - ticket.requested_at) / 1000.0
      ticket.grant(wait_seconds)
      @admitted_waits << wait_seconds
    end
    nil
  end
end
