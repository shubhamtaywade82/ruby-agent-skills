class InvalidOrderState < StandardError; end

class OrdersController
  def create
    { status: 201, body: { ok: true } }
  end
end
