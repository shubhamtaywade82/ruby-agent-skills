# frozen_string_literal: true

# Raised by InboxStore#insert when (consumer, message_id) already has a row:
# the unique constraint is the deduplication key.
class DuplicateMessageError < StandardError
end

class InboxStore
  # Durable inbox rows behind a unique (consumer, message_id) constraint.
  # transaction must be all-or-nothing: a raise inside the block leaves the
  # rows exactly as they were before the block started.
  def initialize
    nil
  end

  def insert(consumer, message_id)
    nil
  end

  def include?(consumer, message_id)
    nil
  end

  def size
    nil
  end

  # Append-only audit trail of [:begin], [:insert, consumer, message_id],
  # [:commit], and [:rollback] entries, in execution order.
  def journal
    nil
  end

  def transaction
    nil
  end
end

class OrdersLedger
  # The side-effect recorder. apply! appends one visible effect entry;
  # fail_next! makes the next apply! raise after appending, so transaction
  # and rollback semantics are exercised; rollback_to(savepoint) removes
  # every effect appended after the savepoint.
  def initialize
    nil
  end

  def apply!(message)
    nil
  end

  def applied
    nil
  end

  def fail_next!
    nil
  end

  def rollback_to(savepoint)
    nil
  end
end

class OrderConsumer
  # Consumes at-least-once deliveries exactly once: insert the inbox row
  # and apply the side effect inside one transaction, treat a duplicate
  # message_id as already processed, and leave neither the inbox row nor
  # the effect behind when the transaction aborts.
  def initialize(store:, ledger:, consumer_name:)
    nil
  end

  def consume(message)
    nil
  end
end
