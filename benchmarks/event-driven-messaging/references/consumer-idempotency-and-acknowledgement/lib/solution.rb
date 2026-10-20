# frozen_string_literal: true

# Transactional idempotent consumption: the deduplication reservation is a
# durable write that happens before any effect, effects and reservation share
# one transaction (a failure rolls both back so redelivery can reprocess),
# and the acknowledgement is emitted only after the commit succeeds.
class DeduplicationStore
  attr_reader :reserved

  def initialize
    @reserved = {}
  end

  def reserve!(message_id)
    return false if @reserved.key?(message_id)

    @reserved[message_id] = true
    true
  end

  def include?(message_id)
    @reserved.key?(message_id)
  end

  def release!(message_id)
    @reserved.delete(message_id)
    nil
  end
end

class EffectsRecorder
  attr_reader :applied

  def initialize
    @applied = []
    @fail_next = false
  end

  def fail_next!
    @fail_next = true
  end

  def call(message)
    @applied << { "message_id" => message.fetch("message_id"), "effect" => "user-visible" }

    return unless @fail_next

    @fail_next = false
    raise "effect handler failed"
  end

  def rollback_to(savepoint)
    @applied.pop(@applied.length - savepoint)
    nil
  end
end

class IdempotentConsumer
  attr_reader :journal

  def initialize(store:, handler:)
    @store = store
    @handler = handler
    @journal = []
  end

  def consume(message)
    return rejected unless valid_identity?(message)

    message_id = message.fetch("message_id")

    unless @store.reserve!(message_id)
      @journal << [:ack_duplicate, message_id]

      return { "status" => "duplicate", "acked" => true, "effects_applied" => false }
    end

    @journal << [:reserve, message_id]
    @journal << [:persist, message_id]

    savepoint = @handler.applied.length

    begin
      @handler.call(message)
      @journal << [:effect, message_id]
    rescue StandardError
      @handler.rollback_to(savepoint)
      @journal << [:rollback, message_id]
      @store.release!(message_id)
      @journal << [:release, message_id]

      return { "status" => "failed", "acked" => false, "effects_applied" => false }
    end

    @journal << [:commit, message_id]
    @journal << [:ack, message_id]

    { "status" => "processed", "acked" => true, "effects_applied" => true }
  end

  private

  def rejected
    { "status" => "rejected", "acked" => false, "effects_applied" => false }
  end

  def valid_identity?(message)
    message.is_a?(Hash) && !message["message_id"].to_s.empty?
  end
end
