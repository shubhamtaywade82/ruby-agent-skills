require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "builds a valid order" do
    assert build_order.valid?
  end
end
