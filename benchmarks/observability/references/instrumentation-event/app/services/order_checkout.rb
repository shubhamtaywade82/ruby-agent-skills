class OrderCheckout
  EVENT = "checkout.completed"

  def initialize(order)
    @order = order
  end

  # The notification is observational: subscribers receive a minimal,
  # low-cardinality payload after the business result is determined, and
  # the return value is unchanged.
  def call
    result = true
    ActiveSupport::Notifications.instrument(EVENT, order_id: @order.id) if result
    result
  end
end
