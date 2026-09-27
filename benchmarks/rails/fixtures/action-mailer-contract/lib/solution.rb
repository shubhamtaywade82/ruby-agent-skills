# frozen_string_literal: true
class SecurityMailer
  def initialize(users:) = @users=users
  def security_notice(user_id:,tenant_id:)
    raise NotImplementedError
  end
  def deliver_later(user_id:,tenant_id:)
    raise NotImplementedError
  end
end
