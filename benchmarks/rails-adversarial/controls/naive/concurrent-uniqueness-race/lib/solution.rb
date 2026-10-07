# frozen_string_literal: true

# Negative control: check-then-insert with no storage constraint. Passes the
# visible tests; must fail the withheld ones.

require_relative "store"

module Schema
  def self.migrate(store); end
end

class SignupService
  def initialize(store)
    @store = store
  end

  def register(email:)
    normalized = email.to_s.strip.downcase
    @store.find_by(:users, email: normalized) || @store.insert(:users, email: normalized)
  end
end
