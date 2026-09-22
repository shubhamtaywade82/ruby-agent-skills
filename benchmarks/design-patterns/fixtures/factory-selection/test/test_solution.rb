require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_formats
    assert_instance_of JsonParser, ParserFactory.for(:json)
    assert_instance_of CsvParser, ParserFactory.for(:csv)
  end
end
