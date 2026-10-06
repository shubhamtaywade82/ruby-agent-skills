# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Withheld from the agent workspace: clients retry checkout with the same
# request_id after a timeout or a server error.
class CheckoutWithheldTest < Minitest::Test
  # The cart status write fails once, after the order row is written, as a
  # lost database connection would.
  class FlakyStore < Store
    def update(table, id, attributes)
      if table == :carts && !@failed_once
        @failed_once = true
        raise IOError, "connection lost"
      end
      super
    end
  end

  def setup_with(store)
    @store = store
    Schema.migrate(@store)
    @cart = @store.insert(:carts, email: "ada@example.com", total_cents: 4200, status: "open")
    @gateway = PaymentGateway.new
    @mailer = Mailer.new
  end

  def checkout
    Checkout.new(store: @store, gateway: @gateway, mailer: @mailer)
            .call(cart_id: @cart.fetch(:id), request_id: "req-1")
  end

  def test_retry_after_success_charges_and_mails_once
    setup_with(Store.new)
    first = checkout
    second = checkout

    assert_equal first.fetch(:id), second.fetch(:id)
    assert_equal 1, @gateway.charges.length
    assert_equal 1, @mailer.deliveries.length
  end

  def test_retry_after_a_failed_attempt_charges_and_mails_once
    setup_with(FlakyStore.new)
    begin
      checkout
    rescue IOError
      nil # the client sees a 500 and retries
    end
    order = checkout

    assert_equal 1, @gateway.charges.length
    assert_equal 1, @store.where(:orders, cart_id: @cart.fetch(:id)).length
    assert_equal [order.fetch(:id)], @mailer.deliveries.map { |delivery| delivery.fetch(:order_id) }
  end
end
