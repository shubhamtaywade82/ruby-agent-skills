# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/counter"

class CounterTest < Minitest::Test
  def test_concurrent_increments
    counter = Counter.new
    threads = Array.new(10) do
      Thread.new { 100.times { counter.increment } }
    end
    threads.each(&:join)

    assert_equal 1000, counter.value
  end
end
