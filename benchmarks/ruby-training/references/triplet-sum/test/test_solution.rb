# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Public evaluation cases from evals/ruby-training/triplet-sum.yml.
class TripletSumTest < Minitest::Test
  def test_source_example
    triplet = TripletSum.new.find([12, 3, 4, 1, 6, 9], 25)
    assert_equal triplet.sort, triplet
    assert_equal 25, triplet.sum
  end

  def test_negative_values
    triplet = TripletSum.new.find([-1, 0, 1, 2, -1, -4], 0)
    assert_equal triplet.sort, triplet
    assert_equal 0, triplet.sum
  end

  def test_no_match
    assert_nil TripletSum.new.find([1, 2, 4, 8], 20)
  end

  def test_too_short
    assert_nil TripletSum.new.find([1, 2], 3)
  end
end
