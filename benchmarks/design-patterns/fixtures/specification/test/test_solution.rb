require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_active
    assert ActiveCustomerSpecification.new.satisfied_by?(Customer.new(true, false))
    refute ActiveCustomerSpecification.new.satisfied_by?(Customer.new(false, true))
  end

  def test_premium
    assert PremiumSpecification.new.satisfied_by?(Customer.new(true, true))
    refute PremiumSpecification.new.satisfied_by?(Customer.new(true, false))
  end
end
