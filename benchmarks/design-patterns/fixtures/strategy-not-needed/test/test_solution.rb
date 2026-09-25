require "minitest/autorun"
require_relative "../lib/solution"

class ShippingCostTest < Minitest::Test
  def test_calculates_shipping_cost
    shipping = ShippingCost.new(weight_grams: 1_000)

    assert_equal 2_500, shipping.cents
  end
end
