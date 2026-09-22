# frozen_string_literal: true
class MaintenanceRunner
  def initialize(records:) = @records=records
  def dry_run(limit:) = @records.first(limit).map{|r| r[:id]}
  def run(batch_size:,lock:)
    raise "locked" if lock
    @records.each_slice(batch_size).map{|batch| batch.map{|r| r[:id]}}
  end
  def verify(expected_ids:) = expected_ids.sort == @records.map{|r|r[:id]}.sort
  def report(processed:,failed:) = {processed:,failed:failed.map{|r|r[:id]}}
end
