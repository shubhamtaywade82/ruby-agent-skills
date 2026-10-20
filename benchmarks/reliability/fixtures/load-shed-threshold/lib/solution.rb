# frozen_string_literal: true

class LoadShedder
  # Load shedding with hysteresis. observe records the saturation signal and
  # drives the shed state machine: shedding engages when the signal reaches
  # shed_above and clears only when it drops below the lower recover_below
  # bound, so a signal oscillating between the two bounds cannot flap the
  # shed on and off. check returns the decision for one request: allowed
  # requests pass through, shed requests get a 503 with Retry-After, and
  # every shed decision appends an observable event carrying the reason,
  # threshold, and current signal value.
  def initialize(shed_above:, recover_below:, retry_after_seconds: 30)
    nil
  end

  def observe(signal_value)
    nil
  end

  def check
    nil
  end

  def events
    nil
  end
end
