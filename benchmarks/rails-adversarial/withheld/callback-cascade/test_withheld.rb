# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Withheld from the agent workspace: lifecycle side effects must hold their
# exactly-once contract across the write paths the visible tests leave out.
class MemberLifecycleWithheldTest < Minitest::Test
  def setup
    @store = Store.new
    @store.add_unique_index(:members, :email)
    Member.connect(@store)
    Mailer.reset
  end

  def test_updating_a_member_never_sends_another_welcome_email
    member = Membership.signup(email: "ada@example.com", name: "Ada")

    Membership.update_profile(member_id: member.id, name: "Ada Lovelace")
    Membership.update_profile(member_id: member.id, name: "A. Lovelace")

    assert_equal 1, Mailer.deliveries.length
    assert_equal member.id, Mailer.deliveries.first.fetch(:member_id)
  end

  def test_imported_members_each_receive_exactly_one_welcome_email
    Membership.import_members([
      { email: "grace@example.com", name: "Grace" },
      { email: "alan@example.com", name: "Alan" },
      { email: "katherine@example.com", name: "Katherine" }
    ])

    assert_equal 3, Mailer.deliveries.length
    created_ids = @store.where(:members, {}).map { |row| row.fetch(:id) }.sort
    delivered_to = Mailer.deliveries.map { |delivery| delivery.fetch(:member_id) }.sort

    assert_equal created_ids, delivered_to
  end
end
