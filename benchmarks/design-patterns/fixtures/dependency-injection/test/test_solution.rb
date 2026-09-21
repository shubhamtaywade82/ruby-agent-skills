require "minitest/autorun"
require_relative "../lib/solution"

class FakeClock
  def now
    "2026-09-21T10:00:00Z"
  end
end

class TestSolution < Minitest::Test
  def test_uses_injected_clock
    assert_equal "2026-09-21T10:00:00Z", ReportGenerator.new(clock: FakeClock.new).generated_at
  end
end
