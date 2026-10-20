# frozen_string_literal: true

# Transactional outbox: the order row and its outbox entry commit in one
# transaction, the relay publishes only after commit, duplicate relay runs
# are a no-op, and the broker deduplicates on message id so a relay crash
# between send and mark re-publishes safely.
class OutboxRelayCrash < StandardError
end

class TransactionalStore
  attr_reader :orders, :outbox_entries, :journal

  def initialize
    @orders = {}
    @outbox_entries = []
    @journal = []
    @fail_next_order = false
  end

  def fail_next_order!
    @fail_next_order = true
    nil
  end

  def insert_order(order_id, amount)
    if @fail_next_order
      @fail_next_order = false
      raise "order insert failed"
    end

    @orders[order_id] = { "order_id" => order_id, "amount" => amount }
    @journal << [:insert_order, order_id]
    nil
  end

  def insert_outbox(order_id, message_id)
    order = @orders.fetch(order_id)
    @outbox_entries << {
      "order_id" => order_id,
      "message_id" => message_id,
      "published" => false,
      "payload" => { "order_id" => order_id, "amount" => order.fetch("amount") }
    }
    @journal << [:insert_outbox, message_id]
    nil
  end

  def unpublished_entries
    @outbox_entries.reject { |entry| entry.fetch("published") }
  end

  def mark_published!(message_id)
    entry = @outbox_entries.find { |candidate| candidate.fetch("message_id") == message_id }
    entry["published"] = true if entry
    nil
  end

  def transaction
    @journal << [:begin]
    orders_snapshot = @orders.dup
    outbox_snapshot = @outbox_entries.dup
    begin
      result = yield
      @journal << [:commit]
      result
    rescue StandardError
      @orders = orders_snapshot
      @outbox_entries = outbox_snapshot
      @journal << [:rollback]
      raise
    end
  end
end

class MessageBroker
  attr_reader :messages

  def initialize
    @messages = []
    @published_ids = []
  end

  def publish(message_id, payload)
    return false if @published_ids.include?(message_id)

    @published_ids << message_id
    @messages << { "message_id" => message_id, "payload" => payload }
    true
  end
end

class CheckoutService
  def initialize(store:)
    @store = store
  end

  def place_order(order_id:, amount:)
    message_id = "msg-#{order_id}"

    begin
      @store.transaction do
        @store.insert_order(order_id, amount)
        @store.insert_outbox(order_id, message_id)
      end
    rescue StandardError
      return { "status" => "failed" }
    end

    { "status" => "placed", "message_id" => message_id }
  end
end

class OutboxRelay
  attr_accessor :crash_after_publish

  def initialize(store:, broker:)
    @store = store
    @broker = broker
    @crash_after_publish = false
  end

  def run
    @store.unpublished_entries.each do |entry|
      message_id = entry.fetch("message_id")
      @broker.publish(message_id, entry.fetch("payload"))
      raise OutboxRelayCrash, "relay crashed after publishing #{message_id}" if @crash_after_publish

      @store.mark_published!(message_id)
    end
    nil
  end
end
