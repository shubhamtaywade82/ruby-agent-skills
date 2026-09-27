# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Public evaluation cases from evals/ruby-training/distinct-elements.yml.
class DistinctElementsTest < Minitest::Test
  def test_source_example
    assert_equal [1, 4, 6, 7, 8, 10], DistinctElements.new.find([4, 7, 4, 1, 1, 4, 8, 10, 6, 7])
  end

  def test_repeated_values
    assert_equal [6], DistinctElements.new.find([6, 6, 6, 6])
  end

  def test_already_distinct
    assert_equal [1, 2, 3], DistinctElements.new.find([1, 2, 3])
  end

  def test_empty
    assert_equal [], DistinctElements.new.find([])
  end
end
