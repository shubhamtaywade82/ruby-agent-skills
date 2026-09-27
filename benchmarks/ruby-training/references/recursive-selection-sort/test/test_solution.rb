# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Public evaluation cases from evals/ruby-training/recursive-selection-sort.yml.
class RecursiveSelectionSorterTest < Minitest::Test
  def test_unsorted
    assert_equal [11, 12, 22, 25, 64], RecursiveSelectionSorter.new.sort([64, 25, 12, 22, 11])
  end

  def test_duplicates
    assert_equal [1, 1, 2, 3, 3], RecursiveSelectionSorter.new.sort([3, 1, 3, 2, 1])
  end

  def test_singleton
    assert_equal [7], RecursiveSelectionSorter.new.sort([7])
  end

  def test_empty
    assert_equal [], RecursiveSelectionSorter.new.sort([])
  end
end
