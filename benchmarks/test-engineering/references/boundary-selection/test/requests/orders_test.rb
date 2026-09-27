require "test_helper"

class OrdersTest < ActionDispatch::IntegrationTest
  test "creates an order through the HTTP contract" do
    post orders_url, params: { order: { sku: "SKU-1" } }
    assert_response :created
    assert_equal "application/json", response.media_type
    assert Order.exists?(sku: "SKU-1")
  end
end
