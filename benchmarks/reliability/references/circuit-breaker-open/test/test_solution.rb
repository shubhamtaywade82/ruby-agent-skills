# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class CircuitBreakerOpenReferenceTest < Minitest::Test
  def test_reference_opens_recovers_and_reopens
    clock = Clock.new
    gateway = GatewayStub.new(responses: [{ "status" => 503 }] * 3 +
                                       [{ "status" => 200 }] + [{ "status" => 503 }] * 4)
    circuit = CircuitBreaker.new(clock: clock, dependency: gateway, failure_threshold: 3,
                                 reset_timeout_ms: 10_000)

    3.times { circuit.call("charge") }
    assert_equal :open, circuit.state

    clock.advance(10_000)
    assert_equal "success", circuit.call("charge").fetch("outcome")
    assert_equal :closed, circuit.state

    3.times { circuit.call("charge") }
    assert_equal :open, circuit.state

    clock.advance(10_000)
    assert_equal "failure", circuit.call("charge").fetch("outcome")
    assert_equal :open, circuit.state

    assert_equal 8, gateway.calls
    assert_equal 6, circuit.events.length
  end
end
