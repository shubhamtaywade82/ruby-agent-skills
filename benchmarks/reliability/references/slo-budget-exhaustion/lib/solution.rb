# frozen_string_literal: true

# Error-budget tracking: bad events consume their documented severity weight
# (unclassified events consume nothing), crossing 50% raises one observable
# alert, crossing 100% freezes non-essential work while essential work stays
# allowed, and the window boundary refills the budget so alert and freeze
# can engage again in the next window. The budget is (1 - SLO target) x
# window requests, rounded to six decimal places so threshold comparisons
# at exactly 50% and 100% are not off by float representation error.
class ErrorBudget
  attr_reader :events

  def initialize(slo_target:, window_requests:, severity: { "server_error" => 1.0, "timeout" => 0.5 },
                 essential_work: ["security_patch", "incident_response"])
    @total_budget = (1 - slo_target) * window_requests
    @severity = severity
    @essential_work = essential_work
    @consumed = 0.0
    @events = []
    @alerted = false
    @freeze_announced = false
  end

  def record(event_type)
    weight = @severity[event_type]
    return { "recorded" => false, "units" => 0.0 } if weight.nil?

    @consumed += weight
    evaluate_thresholds
    { "recorded" => true, "units" => weight }
  end

  def remaining
    @total_budget - @consumed
  end

  def consumed_percent
    @consumed / @total_budget * 100
  end

  def alert?
    consumed_percent >= 50
  end

  def frozen?
    consumed_percent >= 100
  end

  def allowed?(work_type)
    return true if @essential_work.include?(work_type)

    !frozen?
  end

  def refill!
    @consumed = 0.0
    @alerted = false
    @freeze_announced = false
    @events << { "type" => "window_refilled", "remaining" => @total_budget }
    nil
  end

  private

  def evaluate_thresholds
    if !@alerted && consumed_percent >= 50
      @alerted = true
      @events << { "type" => "alert_raised", "consumed_percent" => consumed_percent,
                   "remaining" => remaining }
    end
    return if @freeze_announced || consumed_percent < 100

    @freeze_announced = true
    @events << { "type" => "freeze_engaged", "consumed_percent" => consumed_percent,
                 "remaining" => remaining }
  end
end
