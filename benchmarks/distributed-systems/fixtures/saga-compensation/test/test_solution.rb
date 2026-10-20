# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class SagaCompensationTest < Minitest::Test
  def setup
    @store = SagaStore.new
    @inventory = ServiceSpy.new(name: "inventory")
    @payment = ServiceSpy.new(name: "payment")
    @confirmation = ServiceSpy.new(name: "confirmation")
    @saga = CheckoutSaga.new(saga_id: "s-1", store: @store, inventory: @inventory,
                             payment: @payment, confirmation: @confirmation)
  end

  def test_happy_path_completes_every_step_once_in_order
    @saga.execute

    assert_equal "completed", @saga.status
    assert_equal %w[reserve_inventory charge_payment send_confirmation], @saga.completed_steps
    assert_empty @saga.compensated_steps
    assert_equal 1, @inventory.calls_for(:reserve)
    assert_equal 1, @payment.calls_for(:charge)
    assert_equal 1, @confirmation.calls_for(:send)
    assert_equal 0, @inventory.calls_for(:release)
    assert_equal 0, @payment.calls_for(:refund)
    assert_equal "completed", @store.find("s-1").fetch("status"), "completion is durable"
  end

  def test_payment_failure_compensates_the_reserved_inventory
    @payment.fail_on(:charge)
    @saga.execute

    assert_equal "compensated", @saga.status
    assert_equal %w[reserve_inventory], @saga.completed_steps
    assert_equal %w[reserve_inventory], @saga.compensated_steps
    assert_equal 1, @inventory.calls_for(:reserve)
    assert_equal 1, @inventory.calls_for(:release), "the completed step is compensated"
    assert_equal 0, @payment.calls_for(:refund), "the failed step was never charged"
    assert_equal 0, @confirmation.calls_for(:send)
  end

  def test_failed_compensation_is_recorded_for_manual_intervention
    @payment.fail_on(:charge)
    @inventory.fail_on(:release)
    @saga.execute

    assert_equal "compensation_failed", @saga.status
    assert_equal %w[reserve_inventory], @saga.completed_steps
    assert_equal 1, @saga.compensation_failures.length
    assert_includes @saga.compensation_failures, "reserve_inventory"
    assert_equal 1, @inventory.calls_for(:release), "the failed compensation is not retried forever"

    stored = @store.find("s-1")
    assert_equal "compensation_failed", stored.fetch("status"), "the failure is surfaced durably"
    assert_includes stored.fetch("compensation_failures"), "reserve_inventory"
  end

  def test_crash_resumes_from_the_last_committed_step
    @saga.crash_before_step = "charge_payment"

    assert_raises(SagaCrash) { @saga.execute }

    persisted = @store.find("s-1")
    assert_equal "running", persisted.fetch("status")
    assert_equal %w[reserve_inventory], persisted.fetch("completed_steps"), "state is saved before the crash"

    resumed = CheckoutSaga.new(saga_id: "s-1", store: @store, inventory: @inventory,
                               payment: @payment, confirmation: @confirmation)
    resumed.resume

    assert_equal "completed", resumed.status
    assert_equal %w[reserve_inventory charge_payment send_confirmation], resumed.completed_steps
    assert_equal 1, @inventory.calls_for(:reserve), "resume must not re-run step 1"
    assert_equal 1, @payment.calls_for(:charge)
    assert_equal 1, @confirmation.calls_for(:send)
  end

  def test_compensation_is_idempotent
    @payment.fail_on(:charge)
    @saga.execute

    assert_equal "compensated", @saga.status

    @saga.compensate
    @saga.compensate

    assert_equal 1, @inventory.calls_for(:release), "a second compensation run is a no-op"
    assert_equal "compensated", @saga.status
    assert_empty @saga.compensation_failures
  end
end
