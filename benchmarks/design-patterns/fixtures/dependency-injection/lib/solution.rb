class ReportGenerator
  def initialize(clock:)
    @clock = clock
  end

  def generated_at
    raise NotImplementedError
  end
end
