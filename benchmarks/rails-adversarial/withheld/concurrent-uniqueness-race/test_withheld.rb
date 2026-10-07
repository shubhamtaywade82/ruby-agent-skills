# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Withheld from the agent workspace: production conditions the visible tests
# do not show.
class SignupServiceWithheldTest < Minitest::Test
  # A real database answers reads with latency, so concurrent requests can all
  # observe "no such user" before any of them inserts.
  class SlowReadStore < Store
    def find_by(table, conditions)
      super.tap { sleep 0.01 }
    end
  end

  def test_concurrent_registrations_create_one_user
    store = SlowReadStore.new
    Schema.migrate(store)
    results = Array.new(8) do
      Thread.new { SignupService.new(store).register(email: "ada@example.com") }
    end.map(&:value)

    assert_equal 1, store.count(:users)
    assert_equal 1, results.map { |user| user.fetch(:id) }.uniq.length
  end

  # Other writers (consoles, imports, a second app process) bypass the
  # service, so the invariant must hold at the storage boundary.
  def test_storage_rejects_duplicate_emails_outside_the_service
    store = Store.new
    Schema.migrate(store)
    store.insert(:users, email: "ada@example.com")

    assert_raises(UniqueViolation) { store.insert(:users, email: "ada@example.com") }
  end
end
