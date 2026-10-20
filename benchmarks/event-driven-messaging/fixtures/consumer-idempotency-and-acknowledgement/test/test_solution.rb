# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class ConsumerIdempotencyAcknowledgementTest < Minitest::Test
  def setup
    @store = DeduplicationStore.new
    @handler = EffectsRecorder.new
    @consumer = IdempotentConsumer.new(store: @store, handler: @handler)
    @message = { "message_id" => "msg-0001", "event_type" => "order.placed", "data" => { "order_id" => "o-1" } }
  end

  def test_duplicate_delivery_applies_effects_exactly_once
    first = @consumer.consume(@message)
    second = @consumer.consume(@message)

    assert_equal "processed", first.fetch("status")
    assert_equal "duplicate", second.fetch("status")
    assert second.fetch("acked"), "duplicates are still acknowledged so delivery stops"
    refute second.fetch("effects_applied")
    assert_equal 1, @handler.applied.length
  end

  def test_failed_effects_roll_back_and_allow_redelivery
    @handler.fail_next!
    failed = @consumer.consume(@message)

    assert_equal "failed", failed.fetch("status")
    refute failed.fetch("acked")
    assert_empty @handler.applied, "rolled-back effects must not be visible"
    assert_equal [:release, "msg-0001"], @consumer.journal.last, "failed work releases its reservation"

    retried = @consumer.consume(@message)

    assert_equal "processed", retried.fetch("status")
    assert_equal 1, @handler.applied.length
  end

  def test_dedup_reservation_persists_before_effects
    @consumer.consume(@message)
    journal = @consumer.journal

    persist_index = journal.index([:persist, "msg-0001"])
    effect_index = journal.index([:effect, "msg-0001"])

    refute_nil persist_index, "reservation must be journaled as a durable write"
    refute_nil effect_index
    assert_operator persist_index, :<, effect_index, "deduplication must be durable before any effect runs"
  end

  def test_acknowledgement_is_emitted_only_after_commit
    @consumer.consume(@message)
    journal = @consumer.journal

    commit_index = journal.index([:commit, "msg-0001"])
    ack_index = journal.index([:ack, "msg-0001"])

    refute_nil commit_index
    refute_nil ack_index
    assert_operator commit_index, :<, ack_index, "ack follows commit, never before"
    assert_equal [:ack, "msg-0001"], journal.last, "ack is the final step of a successful consume"
  end

  def test_message_without_identity_is_rejected
    result = @consumer.consume("event_type" => "order.placed")

    assert_equal "rejected", result.fetch("status")
    refute result.fetch("acked")
    assert_empty @handler.applied
  end
end
