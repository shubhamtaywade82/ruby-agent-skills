# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class ShoppingCartTest < Minitest::Test
  def setup
    @mall = Mall.new
    @mall.add_product("Fruity", 12, 2)
    @cart = ShoppingCart.new(@mall)
  end

  def test_add_within_inventory_shows_details_and_total
    @cart.add_product("Fruity", 2)
    assert_equal [{ "name" => "Fruity", "quantity" => 2, "price" => 12, "line_total" => 24 }], @cart.details
    assert_equal 24, @cart.total
  end

  def test_unavailable_product_is_rejected
    error = assert_raises(ShoppingCart::ProductNotAvailable) { @cart.add_product("Slice", 1) }
    assert_includes error.message, "product_not_available"
  end

  def test_inventory_limit_is_respected
    assert_raises(ShoppingCart::InsufficientInventory) { @cart.add_product("Fruity", 3) }
  end

  def test_remove_from_cart
    @cart.add_product("Fruity", 2)
    @cart.remove_product("Fruity", 1)
    assert_equal 12, @cart.total
  end

  def test_cannot_remove_more_than_cart_quantity
    @cart.add_product("Fruity", 1)
    assert_raises(ShoppingCart::InsufficientCartQuantity) { @cart.remove_product("Fruity", 2) }
  end
end
