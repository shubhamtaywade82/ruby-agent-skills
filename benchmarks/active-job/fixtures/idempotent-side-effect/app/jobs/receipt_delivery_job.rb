# frozen_string_literal: true

class ReceiptDeliveryLog
  def self.deliver(receipt_id)
    @deliveries ||= []
    @deliveries << receipt_id
  end

  def self.deliveries
    @deliveries ||= []
  end
end

class ReceiptDeliveryJob
  def self.perform(receipt_id)
    ReceiptDeliveryLog.deliver(receipt_id)
  end
end
