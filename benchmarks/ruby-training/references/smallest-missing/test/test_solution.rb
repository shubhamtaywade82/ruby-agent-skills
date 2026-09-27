# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Public evaluation cases from evals/ruby-training/smallest-missing.yml.
class SmallestMissingTest < Minitest::Test
  def test_source_example
    assert_equal 2, SmallestMissing.new.find([0, 1, 5, 10])
  end

  def test_missing_zero
    assert_equal 0, SmallestMissing.new.find([1, 2, 3])
  end

  def test_missing_middle
    assert_equal 3, SmallestMissing.new.find([0, 1, 2, 4, 5])
  end

  def test_missing_at_end
    assert_equal 4, SmallestMissing.new.find([0, 1, 2, 3])
  end

  def test_empty
    assert_equal 0, SmallestMissing.new.find([])
  end
end
