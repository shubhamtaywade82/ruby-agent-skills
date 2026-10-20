# frozen_string_literal: true

# Durable saga orchestration: each step commits locally before the saga
# state advances, partial failure compensates completed steps in reverse,
# compensations are idempotent, a failed compensation is recorded once for
# manual intervention, and a crashed worker resumes from the last committed
# step without re-running it.
class SagaCrash < StandardError
end

class ServiceSpy
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
  def initialize
    @records = {}
  end

  def save(record)
    @records[record.fetch("saga_id")] = SagaStore.deep_copy(record)
    nil
  end

  def find(saga_id)
    SagaStore.deep_copy(@records[saga_id])
  end

  def self.deep_copy(value)
    case value
    when Hash then value.each_with_object({}) { |(key, item), copy| copy[key] = deep_copy(item) }
    when Array then value.map { |item| deep_copy(item) }
    else value
    end
  end
end

class CheckoutSaga
  STEP_NAMES = %w[reserve_inventory charge_payment send_confirmation].freeze

  attr_accessor :crash_before_step

  def initialize(saga_id:, store:, inventory:, payment:, confirmation:)
    @saga_id = saga_id
    @store = store
    @inventory = inventory
    @payment = payment
    @confirmation = confirmation
    @crash_before_step = nil
  end

  def execute
    record = load_record

    begin
      while record.fetch("completed_steps").length < STEP_NAMES.length
        step_name = STEP_NAMES[record.fetch("completed_steps").length]
        raise SagaCrash, "worker crash before #{step_name}" if @crash_before_step.to_s == step_name

        run_step(step_name)
        record.fetch("completed_steps") << step_name
        @store.save(record)
      end

      record["status"] = "completed"
      @store.save(record)
    rescue StandardError => e
      raise if e.is_a?(SagaCrash)

      record["failed_step"] = STEP_NAMES[record.fetch("completed_steps").length]
      record["status"] = "compensating"
      @store.save(record)
      compensate
    end
    nil
  end

  def resume
    execute
  end

  def compensate
    record = load_record

    record.fetch("completed_steps").reverse.each do |step_name|
      already_done = record.fetch("compensated_steps").include?(step_name) ||
                     record.fetch("compensation_failures").include?(step_name)
      next if already_done

      begin
        run_compensation(step_name)
        record.fetch("compensated_steps") << step_name
      rescue StandardError
        record.fetch("compensation_failures") << step_name
      end
      @store.save(record)
    end

    record["status"] = record.fetch("compensation_failures").empty? ? "compensated" : "compensation_failed"
    @store.save(record)
    nil
  end

  def status
    load_record.fetch("status")
  end

  def completed_steps
    load_record.fetch("completed_steps")
  end

  def compensated_steps
    load_record.fetch("compensated_steps")
  end

  def compensation_failures
    load_record.fetch("compensation_failures")
  end

  private

  def load_record
    existing = @store.find(@saga_id)
    return existing if existing

    record = {
      "saga_id" => @saga_id,
      "status" => "running",
      "completed_steps" => [],
      "compensated_steps" => [],
      "failed_step" => nil,
      "compensation_failures" => []
    }
    @store.save(record)
    record
  end

  def run_step(step_name)
    case step_name
    when "reserve_inventory" then @inventory.call(:reserve, @saga_id, 3)
    when "charge_payment" then @payment.call(:charge, @saga_id, 4200)
    when "send_confirmation" then @confirmation.call(:send, @saga_id, 1)
    end
  end

  def run_compensation(step_name)
    case step_name
    when "reserve_inventory" then @inventory.call(:release, @saga_id, 3)
    when "charge_payment" then @payment.call(:refund, @saga_id, 4200)
    end
  end
end
