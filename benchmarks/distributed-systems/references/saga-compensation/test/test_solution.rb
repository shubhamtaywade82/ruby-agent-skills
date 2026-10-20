# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class SagaCompensationReferenceTest < Minitest::Test
  def test_reference_compensates_partial_failure_and_resumes_after_a_crash
    store = SagaStore.new
    inventory = ServiceSpy.new(name: "inventory")
    payment = ServiceSpy.new(name: "payment")
    confirmation = ServiceSpy.new(name: "confirmation")

    happy = CheckoutSaga.new(saga_id: "happy", store: store, inventory: inventory,
                             payment: payment, confirmation: confirmation)
    happy.execute

    assert_equal "completed", happy.status
    assert_equal 1, inventory.calls_for(:reserve)
    assert_equal 1, payment.calls_for(:charge)

    payment.fail_on(:charge)
    failed = CheckoutSaga.new(saga_id: "s-2", store: store, inventory: inventory,
                              payment: payment, confirmation: confirmation)
    failed.execute

    assert_equal "compensated", failed.status
    assert_equal %w[reserve_inventory], failed.compensated_steps
    assert_equal 1, inventory.calls_for(:release)

    crashed = CheckoutSaga.new(saga_id: "s-3", store: store, inventory: inventory,
                               payment: payment, confirmation: confirmation)
    crashed.crash_before_step = "charge_payment"
    assert_raises(SagaCrash) { crashed.execute }
    assert_equal %w[reserve_inventory], store.find("s-3").fetch("completed_steps")

    reserves_before_resume = inventory.calls_for(:reserve)
    resumed = CheckoutSaga.new(saga_id: "s-3", store: store, inventory: inventory,
                               payment: payment, confirmation: confirmation)
    resumed.resume

    assert_equal "compensated", resumed.status
    assert_equal reserves_before_resume, inventory.calls_for(:reserve), "resume does not re-run step 1"
    assert_equal 2, inventory.calls_for(:release), "the resumed saga compensates its own step-2 failure"
  end
end
