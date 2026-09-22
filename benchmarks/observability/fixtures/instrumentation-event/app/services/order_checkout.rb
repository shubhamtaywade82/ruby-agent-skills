class OrderCheckout
  def initialize(order)
    @order = order
  end

  def call
    true
  end
end
