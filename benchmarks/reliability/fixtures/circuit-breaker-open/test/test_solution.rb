# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class CircuitBreakerOpenTest < Minitest::Test
  def breaker(clock:, responses:, failure_threshold: 3, reset_timeout_ms: 10_000)
    gateway = GatewayStub.new(responses: responses)
    circuit = CircuitBreaker.new(clock: clock, dependency: gateway, failure_threshold: failure_threshold,
                                 reset_timeout_ms: reset_timeout_ms)
    [circuit, gateway]
  end

  def test_closed_breaker_passes_successful_calls_through
    clock = Clock.new
    circuit, gateway = breaker(clock: clock, responses: [{ "status" => 200 }, { "status" => 200 }])

    first = circuit.call("charge")
    second = circuit.call("charge")

    assert_equal "success", first.fetch("outcome")
    assert_equal "success", second.fetch("outcome")
    assert_equal :closed, circuit.state
    assert_equal 2, gateway.calls
    assert_empty circuit.events
  end

  def test_consecutive_failures_open_the_breaker_with_one_transition_event
    clock = Clock.new
    circuit, gateway = breaker(clock: clock, responses: [{ "status" => 503 }] * 3)

    first = circuit.call("charge")
    second = circuit.call("charge")
    third = circuit.call("charge")

    assert_equal "failure", first.fetch("outcome")
    assert_equal "failure", second.fetch("outcome")
    assert_equal "failure", third.fetch("outcome"), "the call that trips the breaker still fails"
    assert_equal :open, circuit.state
    assert_equal 3, gateway.calls
    opening = circuit.events.select { |event| event.fetch("to") == "open" }
    assert_equal 1, opening.length, "the closed-to-open transition is emitted exactly once"
    assert_equal "closed", opening.first.fetch("from")
  end

  def test_open_breaker_short_circuits_without_calling_the_dependency
    clock = Clock.new
    circuit, gateway = breaker(clock: clock, responses: [{ "status" => 503 }] * 3)

    3.times { circuit.call("charge") }
    calls_after_trip = gateway.calls

    short = circuit.call("charge")

    assert_equal "short_circuited", short.fetch("outcome")
    assert_nil short["response"], "a short-circuit has no outbound response"
    assert_equal calls_after_trip, gateway.calls, "the dependency is not called while open"
    assert_equal 1, circuit.events.length, "short-circuiting emits no new transition"
  end

  def test_half_open_recovers_after_a_successful_probe
    clock = Clock.new
    circuit, = breaker(clock: clock, responses: [{ "status" => 503 }] * 3 +
                                                   [{ "status" => 200 }, { "status" => 200 }])

    3.times { circuit.call("charge") }
    assert_equal :open, circuit.state

    clock.advance(10_000)
    probe = circuit.call("charge")

    assert_equal "success", probe.fetch("outcome")
    assert_equal :closed, circuit.state
    transitions = circuit.events.map { |event| [event.fetch("from"), event.fetch("to")] }
    assert_includes transitions, ["open", "half_open"]
    assert_includes transitions, ["half_open", "closed"]

    after = circuit.call("charge")

    assert_equal "success", after.fetch("outcome")
    assert_equal :closed, circuit.state
  end

  def test_half_open_reopens_when_the_probe_fails
    clock = Clock.new
    circuit, = breaker(clock: clock, responses: [{ "status" => 503 }] * 4)

    3.times { circuit.call("charge") }
    clock.advance(10_000)

    probe = circuit.call("charge")

    assert_equal "failure", probe.fetch("outcome")
    assert_equal :open, circuit.state
    transitions = circuit.events.map { |event| [event.fetch("from"), event.fetch("to")] }
    assert_includes transitions, ["half_open", "open"]

    clock.advance(5_000)
    short = circuit.call("charge")

    assert_equal "short_circuited", short.fetch("outcome"), "the reset timeout restarts after reopening"
    assert_equal :open, circuit.state
  end

  def test_timeouts_and_5xx_count_as_failures_but_4xx_is_success
    clock = Clock.new
    circuit, = breaker(clock: clock, responses: [{ "status" => 503 }, :timeout, { "status" => 404 }] +
                                                   [{ "status" => 503 }] * 3)

    first = circuit.call("charge")
    second = circuit.call("charge")
    third = circuit.call("charge")

    assert_equal "failure", first.fetch("outcome"), "a 503 counts as a failure"
    assert_equal "failure", second.fetch("outcome"), "a timeout counts as a failure"
    assert_equal "success", third.fetch("outcome"), "a 404 means the gateway responded"
    assert_equal :closed, circuit.state

    circuit.call("charge")
    assert_equal :closed, circuit.state, "the 404 success reset the consecutive-failure window"
    circuit.call("charge")
    assert_equal :closed, circuit.state
    circuit.call("charge")

    assert_equal :open, circuit.state, "three fresh consecutive failures reopen the breaker"
  end
end
