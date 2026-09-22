# frozen_string_literal: true

require_relative "../app/jobs/receipt_delivery_job"

ReceiptDeliveryJob.perform(42)
ReceiptDeliveryJob.perform(42)

abort "duplicate side effect" unless ReceiptDeliveryLog.deliveries.count(42) == 1
