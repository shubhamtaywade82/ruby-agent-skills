# frozen_string_literal: true

require_relative "store"
require_relative "services"

module Schema
  def self.migrate(store)
    store.add_unique_index(:orders, :request_id)
  end
end

class Checkout
  def initialize(store:, gateway:, mailer:)
    @store = store
    @gateway = gateway
    @mailer = mailer
  end

  # Returns the order row. A retried request_id reuses the provider's charge
  # (idempotency key) and the stored order, and the confirmation is sent only
  # once the order is committed.
  def call(cart_id:, request_id:)
    existing = @store.find_by(:orders, request_id: request_id)
    return existing if existing

    cart = @store.find_by(:carts, id: cart_id)
    charge_id = @gateway.charge(amount_cents: cart.fetch(:total_cents), idempotency_key: "checkout-#{request_id}")
    order = create_order(cart, charge_id, request_id)
    @mailer.order_confirmation(to: cart.fetch(:email), order_id: order.fetch(:id))
    order
  end

  private

  def create_order(cart, charge_id, request_id)
    @store.transaction do
      order = @store.insert(:orders, cart_id: cart.fetch(:id), charge_id: charge_id,
                                     total_cents: cart.fetch(:total_cents), request_id: request_id)
      @store.update(:carts, cart.fetch(:id), status: "checked_out")
      order
    end
  end
end
