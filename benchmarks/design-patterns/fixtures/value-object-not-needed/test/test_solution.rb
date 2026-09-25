require "minitest/autorun"
require_relative "../lib/solution"

class EmailValidatorTest < Minitest::Test
  def test_validates_basic_email_shape
    validator = EmailValidator.new

    assert validator.valid?("person@example.com")
    refute validator.valid?("person@example")
  end
end
