class ReportGenerator
  def initialize(clock:)
    @clock = clock
  end

  def generated_at
    @clock.now
  end
end
