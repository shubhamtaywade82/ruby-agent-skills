# frozen_string_literal: true

# Raised by OutboxRelay#run when crash_after_publish is enabled: the broker
# already received the message, but the outbox row was not marked published.
class OutboxRelayCrash < StandardError
end

class TransactionalStore
  # The originating database: orders plus outbox rows in one all-or-nothing
  # transaction. fail_next_order! makes the next insert_order raise so
  # rollback semantics are exercised. The journal records [:begin],
  # [:insert_order, order_id], [:insert_outbox, message_id], [:commit], and
  # [:rollback] in execution order.
  def initialize
    nil
  end

  def fail_next_order!
    nil
  end

  def insert_order(order_id, amount)
    nil
  end

  def insert_outbox(order_id, message_id)
    nil
  end

  def orders
    nil
  end

  def outbox_entries
    nil
  end

  def unpublished_entries
    nil
  end

  def mark_published!(message_id)
    nil
  end

  def journal
    nil
  end

  def transaction
    nil
  end
end

class MessageBroker
  # The message broker. publish must be idempotent on message_id: publishing
  # the same message id twice delivers it exactly once.
  def initialize
    nil
  end

  def publish(message_id, payload)
    nil
  end

  def messages
    nil
  end
end

class CheckoutService
  # Places the order and writes its outbox row in one transaction. The
  # publish must not happen when the transaction rolls back.
  def initialize(store:)
    nil
  end

  def place_order(order_id:, amount:)
    nil
  end
end

class OutboxRelay
  attr_accessor :crash_after_publish

  # Publishes unpublished outbox entries after commit and marks them
  # published. Duplicate relay runs must be a no-op. When crash_after_publish
  # is enabled, run raises OutboxRelayCrash after the broker send but before
  # the row is marked, so a retry must re-publish safely.
  def initialize(store:, broker:)
    @store = store
    @broker = broker
    @crash_after_publish = false
  end

  def run
    nil
  end
end
