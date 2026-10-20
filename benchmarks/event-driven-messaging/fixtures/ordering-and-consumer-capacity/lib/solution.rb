# frozen_string_literal: true

class OrderedConsumerGroup
  def initialize(handler:, capacity:, buffer_limit:, max_attempts: 2)
  end

  def enqueue(message)
    nil
  end

  def run
    nil
  end
end
