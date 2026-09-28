# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Public evaluation cases from evals/ruby-training/equilibrium-index.yml.
class EquilibriumIndexTest < Minitest::Test
  def test_interior_equilibrium
    assert_equal 3, EquilibriumIndex.new.find([-7, 1, 5, 2, -4, 3, 0])
  end

  def test_first_of_several
    assert_equal 2, EquilibriumIndex.new.find([1, 3, 5, 2, 2])
  end

  def test_single_element
    assert_equal 0, EquilibriumIndex.new.find([5])
  end

  def test_none_exists
    assert_nil EquilibriumIndex.new.find([1, 2, 3, 4, 5])
  end

  def test_empty
    assert_nil EquilibriumIndex.new.find([])
  end
end
