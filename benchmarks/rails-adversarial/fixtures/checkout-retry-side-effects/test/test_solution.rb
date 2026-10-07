# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class CheckoutTest < Minitest::Test
  def setup
    @store = Store.new
    Schema.migrate(@store)
    @cart = @store.insert(:carts, email: "ada@example.com", total_cents: 4200, status: "open")
    @gateway = PaymentGateway.new
    @mailer = Mailer.new
  end

  def checkout(gateway: @gateway)
    Checkout.new(store: @store, gateway: gateway, mailer: @mailer)
            .call(cart_id: @cart.fetch(:id), request_id: "req-1")
  end

  def test_charges_the_cart_total_and_creates_the_order
    order = checkout

    assert_equal [4200], @gateway.charges.map { |charge| charge.fetch(:amount_cents) }
    assert_equal @cart.fetch(:id), order.fetch(:cart_id)
    assert_equal @gateway.charges.first.fetch(:id), order.fetch(:charge_id)
    assert_equal "checked_out", @store.find_by(:carts, id: @cart.fetch(:id)).fetch(:status)
  end

  def test_sends_one_confirmation
    order = checkout

    assert_equal [{ to: "ada@example.com", order_id: order.fetch(:id) }], @mailer.deliveries
  end

  def test_declined_card_creates_nothing
    assert_raises(CardDeclined) { checkout(gateway: PaymentGateway.new(decline: true)) }

    assert_empty @store.where(:orders, cart_id: @cart.fetch(:id))
    assert_equal "open", @store.find_by(:carts, id: @cart.fetch(:id)).fetch(:status)
    assert_empty @mailer.deliveries
  end
end
