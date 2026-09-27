class User < ApplicationRecord
  has_secure_password
  has_many :notes, dependent: :destroy
  normalizes :email, with: ->(email) { email.strip.downcase }
end
