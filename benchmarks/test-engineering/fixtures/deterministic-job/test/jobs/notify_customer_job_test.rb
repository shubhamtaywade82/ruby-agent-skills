require "test_helper"

class NotifyCustomerJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test "enqueues notification" do
    assert_enqueued_with(job: NotifyCustomerJob, args: [customers(:one).id]) do
      NotifyCustomerJob.perform_later(customers(:one).id)
    end
  end

  test "performs queued notification deterministically" do
    perform_enqueued_jobs do
      NotifyCustomerJob.perform_later(customers(:one).id)
    end

    assert CustomerNotification.exists?(customer_id: customers(:one).id)
  end
end
