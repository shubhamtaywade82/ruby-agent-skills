require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_save_and_find
    store = {}
    repo = OrderRepository.new(store: store)
    order = Order.new(1, "Alice")
    assert_same order, repo.save(order)
    assert_equal "Alice", repo.find(1).customer
  end
end
