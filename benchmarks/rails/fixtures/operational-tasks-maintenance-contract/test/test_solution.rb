# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class MaintenanceRunnerTest < Minitest::Test
  def setup; @runner=MaintenanceRunner.new(records:(1..5).map{|id|{id: id}}); end
  def test_dry_run_does_not_mutate
    before=@runner.dry_run(limit:2); assert_equal [1,2],before
  end
  def test_batching_and_locking_are_bounded
    assert_raises(RuntimeError){@runner.run(batch_size:2,lock:true)}
    assert_equal [[1,2],[3,4],[5]],@runner.run(batch_size:2,lock:false)
  end
  def test_verification_and_report_are_explicit
    assert @runner.verify(expected_ids:[5,4,3,2,1])
    assert_equal({processed:3,failed:[5]},@runner.report(processed:3,failed:[{id:5}]))
  end
end
