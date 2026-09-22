# frozen_string_literal: true

require "securerandom"
require "digest"

class AuthenticationService
  def initialize(users:, sessions:, reset_tokens:, clock: -> { Time.now })
    @users = users
    @sessions = sessions
    @reset_tokens = reset_tokens
    @clock = clock
  end

  def login(email:, password:, pre_auth_session:)
    user = @users.values.find { |candidate| candidate[:email] == email }
    return { status: :invalid } unless user && Digest::SHA256.hexdigest(password) == user[:password_digest]

    session_id = pre_auth_session
    @sessions[session_id] = { user_id: user[:id], authenticated_at: @clock.call }
    { status: :authenticated, session_id: session_id, user_id: user[:id] }
  end

  def logout(session_id:)
    @sessions.delete(session_id)
    { status: :logged_out }
  end

  def request_password_reset(email:)
    token = SecureRandom.hex(16)
    @reset_tokens[token] = {
      email: email,
      expires_at: @clock.call + 900,
      used: false
    }
    { status: :accepted }
  end

  def redeem_password_reset(token:)
    reset = @reset_tokens.fetch(token)
    return :invalid unless reset[:expires_at] > @clock.call && !reset[:used]

    reset[:used] = true
    :accepted
  rescue KeyError
    :invalid
  end
end
