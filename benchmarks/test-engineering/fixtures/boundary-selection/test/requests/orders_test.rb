require "test_helper"

class OrdersTest < ActionController::TestCase
  tests OrdersController

  test "creates an order" do
    controller = OrdersController.new
    get :create, params: { order: { sku: "SKU-1" } }
    assert_equal "SKU-1", controller.instance_variable_get(:@order)&.sku
  end
end
