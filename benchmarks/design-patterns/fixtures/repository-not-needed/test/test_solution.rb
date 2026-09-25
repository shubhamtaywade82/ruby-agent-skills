require "minitest/autorun"
require_relative "../lib/solution"

class InventoryTest < Minitest::Test
  def test_reports_available_sku
    inventory = Inventory.new(items: [{ sku: "A-1", quantity: 2 }])

    assert inventory.available?(sku: "A-1")
    refute inventory.available?(sku: "B-1")
  end
end
