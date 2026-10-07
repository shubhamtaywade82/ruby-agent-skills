# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "openssl"
require_relative "../lib/solution"

# Withheld from the agent workspace: payment providers deliver webhooks at
# least once and retry after any failure.
class PaymentWebhookWithheldTest < Minitest::Test
  SECRET = "whsec_test"

  # The first payment write fails, as a dropped database connection would.
  class FlakyStore < Store
    def insert(table, attributes)
      if table == :payments && !@failed_once
        @failed_once = true
        raise IOError, "connection lost"
      end
      super
    end
  end

  def setup_with(store)
    @store = store
    Schema.migrate(@store)
    @invoice = @store.insert(:invoices, number: "INV-1", status: "open")
    @webhook = PaymentWebhook.new(store: @store, secret: SECRET)
  end

  def deliver
    event = { "id" => "evt_1", "type" => "payment.succeeded",
              "data" => { "invoice_id" => @invoice.fetch(:id), "amount_cents" => 500 } }
    body = JSON.generate(event)
    @webhook.call(body: body, signature: OpenSSL::HMAC.hexdigest("SHA256", SECRET, body))
  end

  def payments
    @store.where(:payments, invoice_id: @invoice.fetch(:id))
  end

  def test_redelivered_event_records_one_payment
    setup_with(Store.new)
    deliver
    deliver

    assert_equal 1, payments.length
  end

  def test_retry_after_a_failed_attempt_records_one_payment
    setup_with(FlakyStore.new)
    begin
      deliver
    rescue IOError
      nil # the provider sees a 500 and retries
    end
    deliver

    assert_equal "paid", @store.find_by(:invoices, id: @invoice.fetch(:id)).fetch(:status)
    assert_equal 1, payments.length
  end
end
