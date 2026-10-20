# frozen_string_literal: true

# Load shedding with hysteresis and observable decisions: the shed engages
# when the saturation signal reaches the upper threshold, stays engaged
# while the signal oscillates between the bounds, clears only below the
# lower recovery bound, and records an event for every shed decision.
class LoadShedder
  attr_reader :events

  def initialize(shed_above:, recover_below:, retry_after_seconds: 30)
    @shed_above = shed_above
    @recover_below = recover_below
    @retry_after_seconds = retry_after_seconds
    @signal = 0.0
    @shedding = false
    @events = []
  end

  def observe(signal_value)
    @signal = signal_value.to_f
    if !@shedding && @signal >= @shed_above
      @shedding = true
      @events << { "type" => "shed_engaged", "reason" => "signal_crossed_threshold",
                   "threshold" => @shed_above, "signal" => @signal }
    elsif @shedding && @signal < @recover_below
      @shedding = false
      @events << { "type" => "shed_released", "reason" => "signal_recovered",
                   "threshold" => @recover_below, "signal" => @signal }
    end
    nil
  end

  def check
    return allowed_decision unless @shedding

    @events << { "type" => "request_shed", "reason" => "load_shed",
                 "threshold" => @shed_above, "signal" => @signal }
    { "allowed" => false, "status" => 503, "retry_after" => @retry_after_seconds,
      "reason" => "load_shed", "signal" => @signal, "threshold" => @shed_above }
  end

  private

  def allowed_decision
    { "allowed" => true, "status" => 200, "retry_after" => nil,
      "reason" => nil, "signal" => @signal, "threshold" => @shed_above }
  end
end
