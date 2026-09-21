require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_pending_not_shippable
    refute Order.new(state: PendingState.new).shippable?
  end

  def test_paid_shippable
    assert Order.new(state: PaidState.new).shippable?
  end
end
