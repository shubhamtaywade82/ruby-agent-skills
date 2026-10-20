# frozen_string_literal: true

# Raised by CheckoutSaga#execute when crash_before_step is set to the step
# it is about to run: the saga state saved so far is durable, and a worker
# resume must continue from the last committed step.
class SagaCrash < StandardError
end

class ServiceSpy
  # Deterministic stand-in for a remote service. call records every
  # invocation as [action, saga_id, amount]; fail_on(action) makes every
  # call with that action raise, so step and compensation failures are
  # scriptable.
  attr_reader :calls

  def initialize(name:)
    @name = name
    @calls = []
    @fail_actions = []
  end

  def fail_on(action)
    @fail_actions << action
    nil
  end

  def call(action, saga_id, amount)
    @calls << [action, saga_id, amount]
    return unless @fail_actions.include?(action)

    raise "#{@name}.#{action} failed"
  end

  def calls_for(action)
    @calls.count { |entry| entry.first == action }
  end
end

class SagaStore
  # Durable saga records. save must persist the record so that a later find
  # (including from a fresh saga instance after a worker crash) observes
  # every state change that was saved, and nothing that was not.
  def initialize
    nil
  end

  def save(record)
    nil
  end

  def find(saga_id)
    nil
  end
end

class CheckoutSaga
  attr_accessor :crash_before_step

  # Coordinates reserve_inventory -> charge_payment -> send_confirmation as
  # local steps with compensating actions (release_inventory, refund
  # payment). State advances only after a step commits, compensation runs in
  # reverse order on partial failure and is idempotent, a failed
  # compensation is recorded for manual intervention, and a crashed saga
  # resumes from the last committed step instead of re-running it.
  def initialize(saga_id:, store:, inventory:, payment:, confirmation:)
    @saga_id = saga_id
    @store = store
    @inventory = inventory
    @payment = payment
    @confirmation = confirmation
    @crash_before_step = nil
  end

  def execute
    nil
  end

  def resume
    nil
  end

  def compensate
    nil
  end

  def status
    nil
  end

  def completed_steps
    nil
  end

  def compensated_steps
    nil
  end

  def compensation_failures
    nil
  end
end
