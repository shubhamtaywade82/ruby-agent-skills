# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Public evaluation cases from evals/ruby-training/power-of-two.yml.
class PowerOfTwoTest < Minitest::Test
  def test_source_not_power
    assert_equal false, PowerOfTwo.new.check?(126)
  end

  def test_source_power
    assert_equal true, PowerOfTwo.new.check?(1024)
  end

  def test_one
    assert_equal true, PowerOfTwo.new.check?(1)
  end

  def test_zero
    assert_equal false, PowerOfTwo.new.check?(0)
  end

  def test_negative
    assert_equal false, PowerOfTwo.new.check?(-2)
  end

  def test_small_power
    assert_equal true, PowerOfTwo.new.check?(2)
  end

  def test_large_powers
    assert PowerOfTwo.new.check?(2**40)
    refute PowerOfTwo.new.check?((2**40) + 1)
  end
end
