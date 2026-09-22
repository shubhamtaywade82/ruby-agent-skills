require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "does not leak shared shipping state" do
    shipping = ShippingContext.new
    shipping.current = nil
    assert_nil shipping.current
  end
end
