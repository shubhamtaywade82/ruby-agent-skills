require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_csv
    assert_equal "csv: data", Report.new(formatter: CsvFormatter.new).render("data")
  end

  def test_pdf
    assert_equal "pdf: data", Report.new(formatter: PdfFormatter.new).render("data")
  end
end
