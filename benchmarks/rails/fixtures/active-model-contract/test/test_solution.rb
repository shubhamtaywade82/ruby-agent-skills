# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class SignupFormTest < Minitest::Test
  def test_validation_errors
    form=SignupForm.new(name:"",email:"bad",password:"short")
    refute form.valid?; assert_includes form.errors,[:name,:blank]
  end
  def test_conversion_and_privacy
    form=SignupForm.new(name:"A",email:"a@test",password:"secretsecret")
    assert_same form,form.to_model; assert_equal "SignupForm",form.model_name; refute form.as_json.key?(:password)
  end
end
