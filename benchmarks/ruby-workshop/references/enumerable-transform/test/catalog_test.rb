require "minitest/autorun"
require_relative "../lib/solution"

class CatalogTest < Minitest::Test
  def test_returns_available_names_in_input_order
    products = [
      { name: "Ruby", available: true },
      { name: "Rails", available: false },
      { name: "PostgreSQL", available: true }
    ]
    assert_equal %w[Ruby PostgreSQL], Catalog.new.available_names(products)
  end

  def test_truthy_non_boolean_is_not_available
    assert_empty Catalog.new.available_names([{ name: "Maybe", available: "yes" }])
  end

  def test_empty_input
    assert_empty Catalog.new.available_names([])
  end
end
