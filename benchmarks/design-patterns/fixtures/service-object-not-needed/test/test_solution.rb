require "minitest/autorun"
require_relative "../lib/solution"

class PriceCalculatorTest < Minitest::Test
  def test_applies_discount
    calculator = PriceCalculator.new(subtotal_cents: 10_000, discount_percent: 15)

    assert_equal 8_500, calculator.total_cents
  end
end
