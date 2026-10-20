# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Test-side scripted handler: :none applies effects, :transient_once fails
# once then succeeds, :transient_always fails every attempt, :permanent
# raises the poison-message error that must skip retries entirely.
class ScriptedHandler
  attr_reader :calls, :applied
  attr_accessor :fail_mode

  def initialize(fail_mode: :none)
    @fail_mode = fail_mode
    @calls = 0
    @applied = []
  end

  def call(payload)
    @calls += 1

    case @fail_mode
    when :transient_once
      @fail_mode = :none
      raise "transient failure"
    when :transient_always
      raise "transient failure"
    when :permanent
      raise PermanentFailure, "poison message"
    end

    @applied << payload.fetch("idempotency_key")
    nil
  end
end

class RetryDeadLetterReplayTest < Minitest::Test
  def setup
    @policy = RetryPolicy.new(max_attempts: 3)
    @queue = DeadLetterQueue.new
    @handler = ScriptedHandler.new
    @processor = MessageProcessor.new(
      handler: @handler,
      retry_policy: @policy,
      dead_letter_queue: @queue,
      clock: -> { 42 }
    )
    @payload = { "idempotency_key" => "order-42", "event_type" => "order.placed", "data" => {} }
  end

  def test_transient_failure_retries_then_succeeds
    @handler.fail_mode = :transient_once
    result = @processor.process(@payload)

    assert_equal "processed", result.fetch("status")
    assert_equal 2, result.fetch("attempts")
    assert_equal 2, @handler.calls
    assert_empty @queue.entries
    assert_equal 1, @policy.delay_for(1)
    assert_equal 2, @policy.delay_for(2)
    refute @policy.exhausted?(2)
    assert @policy.exhausted?(3)
  end

  def test_permanent_failure_dead_letters_without_retry
    @handler.fail_mode = :permanent
    result = @processor.process(@payload)

    assert_equal "dead_lettered", result.fetch("status")
    assert_equal 1, result.fetch("attempts")
    assert_equal "permanent", result.fetch("reason")
    assert_equal 1, @handler.calls, "poison messages must not be retried"

    entry = @queue.entries.first

    assert_equal "permanent", entry.fetch("reason")
    assert_equal 1, entry.fetch("attempts")
    assert_equal "poison message", entry.fetch("last_error")
  end

  def test_exhausted_retries_record_diagnostics
    @handler.fail_mode = :transient_always
    result = @processor.process(@payload)

    assert_equal "dead_lettered", result.fetch("status")
    assert_equal 3, result.fetch("attempts")
    assert_equal 3, @handler.calls

    entry = @queue.entries.first

    assert_equal "exhausted", entry.fetch("reason")
    assert_equal 3, entry.fetch("attempts")
    assert_equal "transient failure", entry.fetch("last_error")
    assert_equal 42, entry.fetch("failed_at")
    assert_equal @payload, entry.fetch("payload")
  end

  def test_replay_skips_effects_already_applied
    @processor.process(@payload)
    @queue.enqueue(
      "payload" => @payload,
      "attempts" => 3,
      "reason" => "exhausted",
      "last_error" => "redelivery glitch",
      "failed_at" => 1
    )

    results = @processor.replay

    assert_equal 1, results.length
    assert_equal "skipped_already_applied", results.first.fetch("status")
    assert_equal 1, @handler.applied.length, "replay must not double-apply user-visible effects"
    assert_empty @queue.entries
  end

  def test_replay_reprocesses_fixed_failures_exactly_once
    @handler.fail_mode = :permanent
    @processor.process(@payload)
    @handler.fail_mode = :none

    results = @processor.replay

    assert_equal 1, results.length
    assert_equal "processed", results.first.fetch("status")
    assert_equal 1, @handler.applied.length
  end
end
