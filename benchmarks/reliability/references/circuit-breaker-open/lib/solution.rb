# frozen_string_literal: true

# Circuit breaker state machine: closed opens only after enough consecutive
# failures (5xx and timeouts are failures, 4xx is a success because the
# dependency responded), open short-circuits without an outbound call until
# the reset timeout elapses, and a half-open probe either closes the breaker
# or reopens it with a fresh timeout. Every transition emits an event.
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

class GatewayTimeout < StandardError
end

class GatewayStub
  attr_reader :calls

  def initialize(responses:)
    @responses = responses.dup
    @calls = 0
  end

  def post(payload)
    @calls += 1
    response = @responses.shift
    raise GatewayTimeout, "gateway timed out" if response == :timeout

    response
  end
end

class CircuitBreaker
  def initialize(clock:, dependency:, failure_threshold:, reset_timeout_ms:)
    @clock = clock
    @dependency = dependency
    @failure_threshold = failure_threshold
    @reset_timeout_ms = reset_timeout_ms
    @state = :closed
    @consecutive_failures = 0
    @opened_at = nil
    @events = []
  end

  def state
    @state
  end

  def events
    @events
  end

  def call(payload)
    if @state == :open
      if @clock.now >= @opened_at + @reset_timeout_ms
        transition(:half_open)
      else
        return { "outcome" => "short_circuited" }
      end
    end

    response = perform(payload)

    if failure?(response)
      record_failure
      { "outcome" => "failure", "response" => response }
    else
      record_success
      { "outcome" => "success", "response" => response }
    end
  end

  private

  def perform(payload)
    @dependency.post(payload)
  rescue GatewayTimeout
    { "status" => 504, "error" => "timeout" }
  end

  def failure?(response)
    response.is_a?(Hash) && response.fetch("status", 0) >= 500
  end

  def record_failure
    @consecutive_failures += 1
    transition(:open) if @state == :half_open
    transition(:open) if @state == :closed && @consecutive_failures >= @failure_threshold
  end

  def record_success
    @consecutive_failures = 0
    transition(:closed) if @state == :half_open
  end

  def transition(new_state)
    @events << { "from" => @state.to_s, "to" => new_state.to_s, "at" => @clock.now }
    @opened_at = @clock.now if new_state == :open
    @consecutive_failures = 0 if new_state == :closed
    @state = new_state
    nil
  end
end
