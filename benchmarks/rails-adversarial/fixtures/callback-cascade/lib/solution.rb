# frozen_string_literal: true

require_relative "framework"

# Membership owns the member write paths: signup, profile updates, and the
# bulk import. Mailer is the transactional-email provider.
class Membership
  class << self
    def signup(email:, name:)
      raise NotImplementedError
    end

    def update_profile(member_id:, name:)
      raise NotImplementedError
    end

    def import_members(rows)
      raise NotImplementedError
    end
  end
end
