# frozen_string_literal: true

require_relative "framework"

# The welcome email is a lifecycle side effect with an exactly-once contract
# per member. It is delivered by the write path that creates the member:
# an after_save hook would refire on every profile update, and Member.import
# fires no hooks at all, so the delivery is explicit at each creating path.
class Membership
  class << self
    def signup(email:, name:)
      member = Member.new(email: email, name: name, status: "active")
      member.save
      Mailer.deliver_welcome(member.id)
      member
    rescue UniqueViolation
      :taken
    end

    def update_profile(member_id:, name:)
      Member.find(member_id).update(name: name)
    end

    def import_members(rows)
      created = Member.import(rows.map { |row| row.merge(status: "active") })
      created.each { |attributes| Mailer.deliver_welcome(attributes.fetch(:id)) }
      created.map { |attributes| Member.new(attributes) }
    end
  end
end
