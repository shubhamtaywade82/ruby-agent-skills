# frozen_string_literal: true

require_relative "store"

module Schema
  def self.migrate(store)
    store.add_unique_index(:users, :email)
  end
end

class SignupService
  def initialize(store)
    @store = store
  end

  # The unique index is the invariant; a racing insert loses and reads the
  # winner instead of failing the request.
  def register(email:)
    normalized = email.to_s.strip.downcase
    @store.find_by(:users, email: normalized) || @store.insert(:users, email: normalized)
  rescue UniqueViolation
    @store.find_by(:users, email: normalized)
  end
end
