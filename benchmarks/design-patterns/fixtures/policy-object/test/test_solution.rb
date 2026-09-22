require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_pending_owned_order
    actor = Object.new
    assert_equal true, OrderPolicy.new(actor: actor).can_cancel?(Order.new(status: :pending, owner: actor))
  end

  def test_paid_order
    actor = Object.new
    assert_equal false, OrderPolicy.new(actor: actor).can_cancel?(Order.new(status: :paid, owner: actor))
  end
end
