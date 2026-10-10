# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class MembershipTest < Minitest::Test
  def setup
    @store = Store.new
    @store.add_unique_index(:members, :email)
    Member.connect(@store)
    Mailer.reset
  end

  def test_signup_creates_an_active_member_and_sends_the_welcome_email
    member = Membership.signup(email: "ada@example.com", name: "Ada")

    assert_equal "active", member.status
    assert_equal 1, @store.where(:members, email: "ada@example.com").length
    assert_equal 1, Mailer.deliveries.length
    assert_equal member.id, Mailer.deliveries.first.fetch(:member_id)
  end

  def test_signup_for_an_already_registered_email_is_taken
    Membership.signup(email: "ada@example.com", name: "Ada")

    assert_equal :taken, Membership.signup(email: "ada@example.com", name: "Ada Lovelace")
    assert_equal 1, @store.where(:members, email: "ada@example.com").length
  end

  def test_update_profile_changes_the_name
    member = Membership.signup(email: "ada@example.com", name: "Ada")

    assert_equal "Ada", @store.find_by(:members, id: member.id).fetch(:name)

    updated = Membership.update_profile(member_id: member.id, name: "Ada Lovelace")

    assert_equal "Ada Lovelace", updated.name
    assert_equal "Ada Lovelace", @store.find_by(:members, id: member.id).fetch(:name)
  end

  def test_import_members_creates_the_members
    created = Membership.import_members([
      { email: "grace@example.com", name: "Grace" },
      { email: "alan@example.com", name: "Alan" }
    ])

    assert_equal 2, created.length
    assert_equal %w[alan@example.com grace@example.com],
                 @store.where(:members, {}).map { |row| row.fetch(:email) }.sort
  end
end
