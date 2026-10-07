# frozen_string_literal: true

# Negative control: correct on the happy path, but charges without an
# idempotency key and mails inside the transaction, so a failed attempt
# leaves a charge and an email behind and the retry repeats both.

require_relative "store"
require_relative "services"

module Schema
  def self.migrate(store); end
end

class Checkout
  def initialize(store:, gateway:, mailer:)
    @store = store
    @gateway = gateway
    @mailer = mailer
  end

  def call(cart_id:, request_id:)
    cart = @store.find_by(:carts, id: cart_id)
    charge_id = @gateway.charge(amount_cents: cart.fetch(:total_cents))
    @store.transaction do
      order = @store.insert(:orders, cart_id: cart_id, charge_id: charge_id, total_cents: cart.fetch(:total_cents))
      @mailer.order_confirmation(to: cart.fetch(:email), order_id: order.fetch(:id))
      @store.update(:carts, cart_id, status: "checked_out")
      order
    end
  end
end
