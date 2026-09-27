# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Public evaluation cases from evals/ruby-training/chocolate-feast.yml.
class ChocolateFeastTest < Minitest::Test
  def test_source_sample_1
    assert_equal 6, ChocolateFeast.new.call(10, 2, 5)
  end

  def test_source_sample_2
    assert_equal 3, ChocolateFeast.new.call(12, 4, 4)
  end

  def test_source_sample_3
    assert_equal 5, ChocolateFeast.new.call(6, 2, 2)
  end

  def test_no_free_chocolate
    assert_equal 5, ChocolateFeast.new.call(10, 2, 6)
  end

  def test_exact_threshold
    assert_equal 3, ChocolateFeast.new.call(4, 2, 2)
  end

  def test_threshold_below_two_is_rejected
    assert_raises(ArgumentError) { ChocolateFeast.new.call(2, 2, 1) }
  end
end
