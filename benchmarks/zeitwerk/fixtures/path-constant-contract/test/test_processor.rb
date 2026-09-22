# frozen_string_literal: true

require "minitest/autorun"
require_relative "../app/services/payments/processor"

class ProcessorTest < Minitest::Test
  def test_public_constant
    assert_equal :ok, Payments::Processor.new.call
  end
end
