# frozen_string_literal: true

# Bounded retries with dead-letter diagnostics and replay safety: transient
# failures retry up to the policy limit with computed (never slept) backoff,
# permanent failures dead-letter on the first attempt, exhausted retries
# record diagnostic metadata, and replay never double-applies effects that
# already completed.
class PermanentFailure < StandardError; end

class RetryPolicy
  attr_reader :max_attempts

  def initialize(max_attempts: 3)
    @max_attempts = max_attempts
  end

  def delay_for(attempt)
    (2**(attempt - 1))
  end

  def exhausted?(attempt)
    attempt >= @max_attempts
  end
end

class DeadLetterQueue
  attr_reader :entries

  def initialize
    @entries = []
  end

  def enqueue(entry)
    @entries << entry
    nil
  end

  def drain
    drained = @entries
    @entries = []
    drained
  end
end

class MessageProcessor
  def initialize(handler:, retry_policy:, dead_letter_queue:, clock: -> { Time.now.to_i })
    @handler = handler
    @retry_policy = retry_policy
    @dead_letter_queue = dead_letter_queue
    @clock = clock
    @applied = []
  end

  def process(payload)
    key = payload["idempotency_key"]

    if key && @applied.include?(key)
      return { "status" => "skipped_already_applied", "attempts" => 0, "dead_lettered" => false }
    end

    attempt = 0

    begin
      attempt += 1
      @handler.call(payload)
    rescue PermanentFailure => e
      return dead_letter(payload, attempt, "permanent", e)
    rescue StandardError => e
      retry if attempt < @retry_policy.max_attempts

      return dead_letter(payload, attempt, "exhausted", e)
    end

    @applied << key if key

    { "status" => "processed", "attempts" => attempt, "dead_lettered" => false }
  end

  def replay
    @dead_letter_queue.drain.map { |entry| process(entry.fetch("payload")) }
  end

  private

  def dead_letter(payload, attempts, reason, error)
    @dead_letter_queue.enqueue(
      "payload" => payload,
      "attempts" => attempts,
      "reason" => reason,
      "last_error" => error.message,
      "failed_at" => @clock.call
    )

    { "status" => "dead_lettered", "attempts" => attempts, "reason" => reason, "dead_lettered" => true }
  end
end
