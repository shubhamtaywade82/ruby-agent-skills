require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_builds_report
    report = ReportBuilder.new.add_header("Title").add_section("Body").add_section("Footer").build
    assert_equal "Title", report.header
    assert_equal ["Body", "Footer"], report.sections
  end
end
