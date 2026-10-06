# frozen_string_literal: true

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

  # Returns :processed, :ignored, or :rejected.
  def call(body:, signature:)
    return :rejected unless authentic?(body, signature)

    event = JSON.parse(body)
    return :ignored unless event["type"] == "payment.succeeded"

    record(event)
    :processed
  rescue UniqueViolation
    :processed
  end

  private

  def authentic?(body, signature)
    expected = OpenSSL::HMAC.hexdigest("SHA256", @secret, body)
    OpenSSL.fixed_length_secure_compare(expected, signature.to_s)
  rescue ArgumentError
    false
  end

  # Deliveries are at-least-once: the event id is recorded in the same
  # transaction as its effects, so a redelivery is a no-op and a failed
  # attempt leaves nothing behind to block the retry.
  def record(event)
    data = event.fetch("data")
    @store.transaction do
      @store.insert(:webhook_events, event_id: event.fetch("id"))
      @store.update(:invoices, data.fetch("invoice_id"), status: "paid")
      @store.insert(:payments, invoice_id: data.fetch("invoice_id"), amount_cents: data.fetch("amount_cents"))
    end
  end
end
