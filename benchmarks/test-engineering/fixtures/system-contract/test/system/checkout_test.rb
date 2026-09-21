require "application_system_test_case"

class CheckoutTest < ApplicationSystemTestCase
  test "updates total and confirms checkout" do
    visit checkout_path
    click_on "Shipping"
    assert_text "$10.00"
    click_on "Complete checkout"
    assert_text "Order confirmed"
  end
end
