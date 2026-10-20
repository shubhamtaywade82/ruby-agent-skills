# frozen_string_literal: true

# At-least-once delivery processed exactly once: the inbox insert and the
# side effect share one all-or-nothing transaction (a failure between them
# leaves neither), the (consumer, message_id) unique constraint is the
# deduplication key, and out-of-order arrival cannot double-apply effects.
class DuplicateMessageError < StandardError
end

class InboxStore
  attr_reader :journal

  def initialize
    @rows = {}
    @journal = []
  end

  def insert(consumer, message_id)
    key = [consumer, message_id]
    raise DuplicateMessageError, "duplicate inbox row for #{consumer}/#{message_id}" if @rows.key?(key)

    @rows[key] = true
    @journal << [:insert, consumer, message_id]
    nil
  end

  def include?(consumer, message_id)
    @rows.key?([consumer, message_id])
  end

  def size
    @rows.length
  end

  def transaction
    @journal << [:begin]
    snapshot = @rows.dup
    begin
      result = yield
      @journal << [:commit]
      result
    rescue StandardError
      @rows = snapshot
      @journal << [:rollback]
      raise
    end
  end
end

class OrdersLedger
  attr_reader :applied

  def initialize
    @applied = []
    @fail_next = false
  end

  def apply!(message)
    @applied << { "message_id" => message.fetch("message_id"),
                  "order_id" => message.fetch("data").fetch("order_id") }
    return unless @fail_next

    @fail_next = false
    raise "side effect failed"
  end

  def fail_next!
    @fail_next = true
    nil
  end

  def rollback_to(savepoint)
    @applied.pop(@applied.length - savepoint)
    nil
  end
end

class OrderConsumer
  def initialize(store:, ledger:, consumer_name:)
    @store = store
    @ledger = ledger
    @consumer_name = consumer_name
  end

  def consume(message)
    message_id = message.fetch("message_id")
    savepoint = @ledger.applied.length

    begin
      @store.transaction do
        @store.insert(@consumer_name, message_id)
        @ledger.apply!(message)
      end
    rescue DuplicateMessageError
      return { "status" => "duplicate" }
    rescue StandardError
      @ledger.rollback_to(savepoint)
      return { "status" => "failed" }
    end

    { "status" => "processed" }
  end
end
