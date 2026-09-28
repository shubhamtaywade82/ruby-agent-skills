# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Public evaluation cases from evals/ruby-training/bubble-sort.yml.
class BubbleSorterTest < Minitest::Test
  def test_unsorted
    assert_equal [1, 2, 4, 5, 8], BubbleSorter.new.sort([5, 1, 4, 2, 8])
  end

  def test_already_sorted
    assert_equal [1, 2, 3, 4], BubbleSorter.new.sort([1, 2, 3, 4])
  end

  def test_reverse_sorted
    assert_equal [1, 2, 3, 4, 5], BubbleSorter.new.sort([5, 4, 3, 2, 1])
  end

  def test_duplicates
    assert_equal [1, 1, 2, 3, 3], BubbleSorter.new.sort([3, 1, 3, 2, 1])
  end

  def test_empty
    assert_equal [], BubbleSorter.new.sort([])
  end
end
