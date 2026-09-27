class ApplicationService
  def self.call(...)
    new(...).call
  end
end

class Order
  attr_accessor :payable, :checked_out
  def initialize(payable: true)
    @payable = payable
    @checked_out = false
  end
end

class Order::Checkout < ApplicationService
  def initialize(order)
    @order = order
  end

  def call
    raise ArgumentError, "order is not payable" unless @order.payable

    @order.checked_out = true
    @order
  end
end
