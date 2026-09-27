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

  def test_value_reads_are_consistent_during_writes
    counter = Counter.new
    writer = Thread.new { 500.times { counter.increment } }
    reads = Array.new(50) { counter.value }
    writer.join

    assert(reads.each_cons(2).all? { |a, b| a <= b })
    assert_equal 500, counter.value
  end
end
