require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_charge
    adapter = StripeAdapter.new(client: VendorGateway.new)
    assert_equal({"ok" => true, "amount" => 5000}, adapter.charge(amount: 5000))
  end
end
