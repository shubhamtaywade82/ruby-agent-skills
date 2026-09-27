# frozen_string_literal: true

class ReceiptDeliveryLog
  # Stand-in for a table with a unique index on receipt_id: the first claim
  # wins and every later claim for the same receipt is a no-op.
  def self.claim(receipt_id)
    @claims ||= {}
    return false if @claims.key?(receipt_id)

    @claims[receipt_id] = true
  end

  def self.deliver(receipt_id)
    @deliveries ||= []
    @deliveries << receipt_id
  end

  def self.deliveries
    @deliveries ||= []
  end
end

class ReceiptDeliveryJob
  # Idempotent under at-least-once execution: the claim precedes the side
  # effect, so a retried or duplicated job never sends a second receipt.
  def self.perform(receipt_id)
    return :already_delivered unless ReceiptDeliveryLog.claim(receipt_id)

    ReceiptDeliveryLog.deliver(receipt_id)
    :delivered
  end
end
