# frozen_string_literal: true

# Per-key ordering with bounded concurrency and buffer limits: messages that
# share a partition key complete in first-in-first-out order, different keys
# are scheduled independently in the same round, at most `capacity` messages
# are in flight per round, a full buffer rejects work instead of growing
# without bound, and a failing lane head retries `max_attempts` times before
# it is dead-lettered so the lane — and every other lane — keeps progressing.
class OrderedConsumerGroup
  attr_reader :completions, :dead_letters, :in_flight_max

  def initialize(handler:, capacity:, buffer_limit:, max_attempts: 2)
    raise ArgumentError, "capacity must be >= 1" if capacity < 1
    raise ArgumentError, "buffer_limit must be >= 1" if buffer_limit < 1

    @handler = handler
    @capacity = capacity
    @buffer_limit = buffer_limit
    @max_attempts = max_attempts
    @lanes = {}
    @attempts = Hash.new(0)
    @buffered = 0
    @completions = []
    @dead_letters = []
    @in_flight_max = 0
  end

  def enqueue(message)
    return { "status" => "rejected", "reason" => "buffer_full" } if @buffered >= @buffer_limit

    key = message.fetch("key")
    @lanes[key] ||= []
    @lanes[key] << message
    @buffered += 1

    { "status" => "accepted" }
  end

  def run
    until lanes_empty?
      flight = []

      @lanes.each do |key, lane|
        break if flight.length >= @capacity

        flight << [key, lane.shift] unless lane.empty?
      end

      @in_flight_max = flight.length if flight.length > @in_flight_max

      flight.each do |key, message|
        id = message.fetch("id")

        if @handler.call(message) == :ok
          @completions << id
          @buffered -= 1
        else
          attempts = @attempts[id] + 1
          @attempts[id] = attempts

          if attempts >= @max_attempts
            @dead_letters << { "message" => message, "attempts" => attempts, "reason" => "exhausted" }
            @buffered -= 1
          else
            @lanes[key].unshift(message)
          end
        end
      end
    end
  end

  private

  def lanes_empty?
    @lanes.each_value.none? { |lane| lane.any? }
  end
end
