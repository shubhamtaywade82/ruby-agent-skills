# frozen_string_literal: true
class SignupForm
  attr_accessor :name,:email,:password
  def initialize(name:,email:,password:) = raise(NotImplementedError)
  def valid?
    raise NotImplementedError
  end
  def errors = raise(NotImplementedError)
  def to_model = raise(NotImplementedError)
  def model_name = raise(NotImplementedError)
  def as_json = raise(NotImplementedError)
end
