# frozen_string_literal: true

class Clock
  # Deterministic clock: now returns integer milliseconds and advance moves
  # time forward by the given milliseconds, so reset timeouts are simulated
  # without sleeping.
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
  # Scripted payment gateway. post pops the next scripted response and
  # counts every outbound call, so tests can prove that an open breaker
  # short-circuits without touching the dependency. A :timeout entry makes
  # post raise GatewayTimeout.
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
  # Failure threshold and reset timeout are configurable. closed opens only
  # after failure_threshold consecutive failures (5xx and timeouts count;
  # 4xx is a success because the gateway responded). open short-circuits
  # calls without an outbound request until reset_timeout_ms has elapsed,
  # then a half-open probe either closes the breaker or reopens it with a
  # fresh timeout. Every transition is recorded as an observable event.
  def initialize(clock:, dependency:, failure_threshold:, reset_timeout_ms:)
    nil
  end

  def call(payload)
    nil
  end

  def state
    nil
  end

  def events
    nil
  end
end
