# frozen_string_literal: true
class SignupForm
  attr_accessor :name,:email,:password
  def initialize(name:,email:,password:) = (@name,@email,@password=name,email,password;@errors=[])
  def valid?
    @errors=[]
    @errors << [:name,:blank] if name.to_s.strip.empty?
    @errors << [:email,:invalid] unless email.to_s.include?("@")
    @errors << [:password,:too_short] if password.to_s.length<8
    @errors.empty?
  end
  def errors = @errors.dup
  def to_model = self
  def model_name = "SignupForm"
  def as_json = {name:name,email:email}
end
