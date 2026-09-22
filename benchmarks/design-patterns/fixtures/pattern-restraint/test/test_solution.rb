require "minitest/autorun"
require_relative "../lib/solution"

class TestSolution < Minitest::Test
  def test_full_name
    assert_equal "Sam Taylor", User.new(first_name: "Sam", last_name: "Taylor").full_name
  end
end
