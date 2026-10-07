# frozen_string_literal: true

# Negative control: verifies the signature and applies effects, but neither
# deduplicates deliveries nor makes the effects atomic. Passes the visible
# tests; must fail the withheld ones.

require "json"
require "openssl"
require_relative "store"

module Schema
  def self.migrate(store); end
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
    @store.update(:invoices, data.fetch("invoice_id"), status: "paid")
    @store.insert(:payments, invoice_id: data.fetch("invoice_id"), amount_cents: data.fetch("amount_cents"))
    :processed
  end
end
