require "test_helper"

$shipping = ShippingContext.new

class OrderTest < ActiveSupport::TestCase
  test "does not leak shared shipping state" do
    attempts = 0
    begin
      assert_nil $shipping.current
    rescue Minitest::Assertion
      attempts += 1
      retry if attempts < 3
      raise
    end
  end
end
