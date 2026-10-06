# frozen_string_literal: true

# Negative control: deduplicates by event id but records the event outside a
# transaction, so a failed attempt marks the event done and the retry is
# skipped. Must fail the withheld retry test.

require "json"
require "openssl"
require_relative "store"

module Schema
  def self.migrate(store)
    store.add_unique_index(:webhook_events, :event_id)
  end
end

class PaymentWebhook
  def initialize(store:, secret:)
    @store = store
    @secret = secret
  end

  def call(body:, signature:)
    expected = OpenSSL::HMAC.hexdigest("SHA256", @secret, body)
    return :rejected unless OpenSSL.fixed_length_secure_compare(expected, signature.to_s)

    event = JSON.parse(body)
    return :ignored unless event["type"] == "payment.succeeded"

    data = event.fetch("data")
    @store.insert(:webhook_events, event_id: event.fetch("id"))
    @store.update(:invoices, data.fetch("invoice_id"), status: "paid")
    @store.insert(:payments, invoice_id: data.fetch("invoice_id"), amount_cents: data.fetch("amount_cents"))
    :processed
  rescue UniqueViolation
    :processed
  end
end
