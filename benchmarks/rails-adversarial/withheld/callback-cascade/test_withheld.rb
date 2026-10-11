# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Withheld from the agent workspace: the welcome email must hold one delivery per
# created member across the write paths the visible tests leave out. Each test
# is one condition, named after its evaluation case, and is graded separately.
class MemberLifecycleWithheldTest < Minitest::Test
  def setup
    @store = Store.new
    @store.add_unique_index(:members, :email)
    Member.connect(@store)
    Mailer.reset
  end

  # Case update-refire: profile updates never deliver another welcome email.
  def test_update_refire
    member = Membership.signup(email: "ada@example.com", name: "Ada")

    Membership.update_profile(member_id: member.id, name: "Ada Lovelace")
    Membership.update_profile(member_id: member.id, name: "A. Lovelace")

    assert_equal 1, Mailer.deliveries.length
    assert_equal member.id, Mailer.deliveries.first.fetch(:member_id)
  end

  # Case import-skips-hooks: bulk-imported members are each welcomed once.
  def test_import_skips_hooks
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
