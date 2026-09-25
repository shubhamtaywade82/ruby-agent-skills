require "minitest/autorun"
require_relative "../lib/solution"

class ReportFormatterTest < Minitest::Test
  def test_formats_one_report_shape
    formatter = ReportFormatter.new

    assert_equal "Revenue: 1200", formatter.format(title: "Revenue", total: 1200)
  end
end
