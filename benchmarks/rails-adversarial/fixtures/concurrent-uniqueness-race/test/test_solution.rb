# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class SignupServiceTest < Minitest::Test
  def setup
    @store = Store.new
    Schema.migrate(@store)
    @service = SignupService.new(@store)
  end

  def test_registers_a_new_user
    user = @service.register(email: "ada@example.com")

    assert_equal "ada@example.com", user.fetch(:email)
    assert_equal 1, @store.count(:users)
  end

  def test_returns_the_existing_user_for_a_known_email
    first = @service.register(email: "ada@example.com")
    second = @service.register(email: "ada@example.com")

    assert_equal first.fetch(:id), second.fetch(:id)
    assert_equal 1, @store.count(:users)
  end

  def test_compares_emails_case_insensitively_ignoring_whitespace
    first = @service.register(email: " Ada@Example.com ")
    second = @service.register(email: "ada@example.com")

    assert_equal first.fetch(:id), second.fetch(:id)
  end

  def test_distinct_emails_get_distinct_users
    refute_equal @service.register(email: "ada@example.com").fetch(:id),
                 @service.register(email: "grace@example.com").fetch(:id)
  end
end
