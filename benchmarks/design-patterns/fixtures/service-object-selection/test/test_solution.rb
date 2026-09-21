require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_checkout
    order = Order.new
    assert_same order, Order::Checkout.call(order)
    assert_equal true, order.checked_out
  end

  def test_rejects_unpayable_order
    order = Order.new(payable: false)
    assert_raises(ArgumentError) { Order::Checkout.call(order) }
    assert_equal false, order.checked_out
  end
end
