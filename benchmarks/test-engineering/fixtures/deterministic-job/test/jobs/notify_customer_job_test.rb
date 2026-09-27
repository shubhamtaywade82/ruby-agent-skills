require "test_helper"

class NotifyCustomerJobTest < ActiveSupport::TestCase
  test "notifies the customer" do
    NotifyCustomerJob.new.perform(customers(:one).id)
    sleep(1)
    assert CustomerNotification.exists?(customer_id: customers(:one).id)
  end
end
