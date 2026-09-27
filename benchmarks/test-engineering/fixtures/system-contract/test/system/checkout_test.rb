require "application_system_test_case"

class CheckoutTest < ApplicationSystemTestCase
  test "calculates the order total" do
    order = Order.new(shipping_method: :standard)
    assert_equal 1000, order.calculate_total
  end
end
