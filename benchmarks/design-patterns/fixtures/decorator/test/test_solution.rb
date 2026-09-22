require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_adds_tax
    base = BasePrice.new(100)
    taxed = TaxedPrice.new(price: base, tax_rate: 0.10)
    assert_equal 110, taxed.total
    assert_equal 100, base.total
  end
end
