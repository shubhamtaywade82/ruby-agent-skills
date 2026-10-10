# frozen_string_literal: true

# Negative control: the welcome email rides an after_save hook on Member, so
# every save delivers again — profile updates included — while the bulk
# import, which fires no hooks, delivers nothing. Passes the visible tests;
# must fail both withheld ones.

require_relative "framework"

class Member
  after_save :deliver_welcome

  def deliver_welcome
    Mailer.deliver_welcome(id)
  end
end

class Membership
  class << self
    def signup(email:, name:)
      Member.new(email: email, name: name, status: "active").save
    rescue UniqueViolation
      :taken
    end

    def update_profile(member_id:, name:)
      Member.find(member_id).update(name: name)
    end

    def import_members(rows)
      Member.import(rows.map { |row| row.merge(status: "active") })
            .map { |attributes| Member.new(attributes) }
    end
  end
end
