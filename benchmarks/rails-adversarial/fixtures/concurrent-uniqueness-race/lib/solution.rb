# frozen_string_literal: true

require_relative "store"

module Schema
  def self.migrate(store); end
end

class SignupService
  def initialize(store)
    @store = store
  end

  def register(email:)
    nil
  end
end
