# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Public evaluation cases from evals/ruby-training/selection-sort.yml.
class SelectionSorterTest < Minitest::Test
  def test_unsorted
    assert_equal [11, 12, 22, 25, 64], SelectionSorter.new.sort([64, 25, 12, 22, 11])
    assert_equal [11, 12, 22, 25, 64], SelectionSorter.new.recursive_sort([64, 25, 12, 22, 11])
  end

  def test_already_sorted
    assert_equal [1, 2, 3, 4], SelectionSorter.new.sort([1, 2, 3, 4])
    assert_equal [1, 2, 3, 4], SelectionSorter.new.recursive_sort([1, 2, 3, 4])
  end

  def test_duplicates
    assert_equal [1, 1, 2, 3, 3], SelectionSorter.new.sort([3, 1, 3, 2, 1])
    assert_equal [1, 1, 2, 3, 3], SelectionSorter.new.recursive_sort([3, 1, 3, 2, 1])
  end

  def test_empty
    assert_equal [], SelectionSorter.new.sort([])
    assert_equal [], SelectionSorter.new.recursive_sort([])
  end
end
