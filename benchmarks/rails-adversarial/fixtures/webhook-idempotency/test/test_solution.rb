# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "openssl"
require_relative "../lib/solution"

class PaymentWebhookTest < Minitest::Test
  SECRET = "whsec_test"

  def setup
    @store = Store.new
    Schema.migrate(@store)
    @invoice = @store.insert(:invoices, number: "INV-1", status: "open")
    @webhook = PaymentWebhook.new(store: @store, secret: SECRET)
  end

  def deliver(event, secret: SECRET)
    body = JSON.generate(event)
    @webhook.call(body: body, signature: OpenSSL::HMAC.hexdigest("SHA256", secret, body))
  end

  def succeeded_event(id: "evt_1", amount_cents: 500)
    { "id" => id, "type" => "payment.succeeded",
      "data" => { "invoice_id" => @invoice.fetch(:id), "amount_cents" => amount_cents } }
  end

  def test_marks_the_invoice_paid_and_records_the_payment
    assert_equal :processed, deliver(succeeded_event)

    assert_equal "paid", @store.find_by(:invoices, id: @invoice.fetch(:id)).fetch(:status)
    payments = @store.where(:payments, invoice_id: @invoice.fetch(:id))
    assert_equal [500], payments.map { |payment| payment.fetch(:amount_cents) }
  end

  def test_rejects_an_invalid_signature_without_changes
    assert_equal :rejected, deliver(succeeded_event, secret: "wrong")

    assert_equal "open", @store.find_by(:invoices, id: @invoice.fetch(:id)).fetch(:status)
    assert_empty @store.where(:payments, invoice_id: @invoice.fetch(:id))
  end

  def test_ignores_unhandled_event_types
    assert_equal :ignored, deliver({ "id" => "evt_2", "type" => "customer.updated", "data" => {} })

    assert_equal "open", @store.find_by(:invoices, id: @invoice.fetch(:id)).fetch(:status)
  end
end
