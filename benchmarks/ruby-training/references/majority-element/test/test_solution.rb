# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Public evaluation cases from evals/ruby-training/majority-element.yml.
class MajorityElementTest < Minitest::Test
  def test_source_no_majority
    assert_equal -1, MajorityElement.new.find([2, 2, 3, 5, 2, 3])
  end

  def test_source_majority
    assert_equal 2, MajorityElement.new.find([2, 2, 3, 5, 2, 3, 2, 2])
  end

  def test_single_element
    assert_equal 7, MajorityElement.new.find([7])
  end

  def test_exact_half
    assert_equal -1, MajorityElement.new.find([1, 1, 2, 2])
  end

  def test_empty
    assert_equal -1, MajorityElement.new.find([])
  end
end
