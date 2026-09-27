# frozen_string_literal: true
class MaintenanceRunner
  def initialize(records:) = @records=records
  def dry_run(limit:) = raise(NotImplementedError)
  def run(batch_size:,lock:)
    raise NotImplementedError
  end
  def verify(expected_ids:) = raise(NotImplementedError)
  def report(processed:,failed:) = raise(NotImplementedError)
end
