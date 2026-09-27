class InvalidOrderState < StandardError; end

class OrdersController
  # Only the expected domain error gets a stable response; anything else
  # propagates to the framework's normal 5xx handling and error reporting.
  RESCUED = { InvalidOrderState => 409 }.freeze

  def initialize(checkout: -> { true })
    @checkout = checkout
  end

  def create
    @checkout.call
    { status: 201, body: { ok: true } }
  rescue InvalidOrderState => e
    { status: RESCUED.fetch(e.class), body: { error: "invalid_order_state" } }
  end
end
