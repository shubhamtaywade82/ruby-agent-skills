# frozen_string_literal: true

require "minitest/autorun"
require_relative "../app/services/payments/processor"

class ProcessorTest < Minitest::Test
  def test_public_api
    assert_equal :ok, PaymentProcessor.new.call
  end
end
