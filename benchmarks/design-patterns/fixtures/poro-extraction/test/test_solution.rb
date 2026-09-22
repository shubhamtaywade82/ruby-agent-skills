require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_total
    assert_equal 110.0, PriceCalculator.new(base_price: 100.0, tax_rate: 0.10).total
  end
end
