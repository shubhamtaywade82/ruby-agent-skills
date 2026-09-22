require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_purchase
    result = Storefront.new(inventory: Inventory.new, pricing: Pricing.new, payment: Payment.new).purchase(sku: "BOOK")
    assert_equal :completed, result
  end
end
