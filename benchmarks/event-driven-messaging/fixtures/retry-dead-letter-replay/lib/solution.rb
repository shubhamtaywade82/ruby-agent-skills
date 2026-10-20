# frozen_string_literal: true

class PermanentFailure < StandardError
end

class RetryPolicy
  def initialize(max_attempts: 3)
  end
end

class DeadLetterQueue
  def enqueue(entry)
    nil
  end

  def drain
    nil
  end
end

class MessageProcessor
  def initialize(handler:, retry_policy:, dead_letter_queue:, clock: nil)
  end

  def process(payload)
    nil
  end

  def replay
    nil
  end
end
