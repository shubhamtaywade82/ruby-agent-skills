# frozen_string_literal: true

# In-memory stand-ins for the payment provider and the mailer. Treat them as
# external services: do not change this file.

class CardDeclined < StandardError; end

class PaymentGateway
  attr_reader :charges

  def initialize(decline: false)
    @decline = decline
    @charges = []
  end

  # A repeated idempotency_key returns the original charge instead of
  # charging again, as real payment providers do.
  def charge(amount_cents:, idempotency_key: nil)
    raise CardDeclined, "card declined" if @decline

    existing = idempotency_key && @charges.find { |charge| charge[:idempotency_key] == idempotency_key }
    return existing[:id] if existing

    id = "ch_#{@charges.length + 1}"
    @charges << { id: id, amount_cents: amount_cents, idempotency_key: idempotency_key }
    id
  end
end

class Mailer
  attr_reader :deliveries

  def initialize
    @deliveries = []
  end

  def order_confirmation(to:, order_id:)
    @deliveries << { to: to, order_id: order_id }
  end
end
