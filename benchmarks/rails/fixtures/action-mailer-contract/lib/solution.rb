# frozen_string_literal: true
class SecurityMailer
  def initialize(users:) = @users=users
  def security_notice(user_id:,tenant_id:)
    u=@users.fetch(user_id)
    return unless u[:tenant_id]==tenant_id
    {to:u[:email],subject:"Security notification",body:"A security-sensitive change occurred."}
  end
  def deliver_later(user_id:,tenant_id:)
    m=security_notice(user_id:,tenant_id:)
    m && {job:"ActionMailer::MailDeliveryJob",arguments:m}
  end
end
