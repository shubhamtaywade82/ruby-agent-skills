# frozen_string_literal: true

class ErrorBudget
  # SLO error-budget tracker. The budget is (1 - SLO target) x window
  # requests in consumable units. record consumes the documented severity
  # weight of a classified bad event and consumes nothing for unclassified
  # events. Crossing 50% consumption raises an observable alert, crossing
  # 100% freezes non-essential work while essential work stays allowed, and
  # refill! restores the full budget on the window boundary.
  def initialize(slo_target:, window_requests:, severity: { "server_error" => 1.0, "timeout" => 0.5 },
                 essential_work: ["security_patch", "incident_response"])
    nil
  end

  def record(event_type)
    nil
  end

  def remaining
    nil
  end

  def consumed_percent
    nil
  end

  def alert?
    nil
  end

  def frozen?
    nil
  end

  def allowed?(work_type)
    nil
  end

  def refill!
    nil
  end

  def events
    nil
  end
end
