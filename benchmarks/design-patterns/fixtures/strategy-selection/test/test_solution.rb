require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_standard
    assert_equal 10, ShippingCost.new(strategy: StandardShipping.new).calculate
  end

  def test_express
    assert_equal 25, ShippingCost.new(strategy: ExpressShipping.new).calculate
  end
end
