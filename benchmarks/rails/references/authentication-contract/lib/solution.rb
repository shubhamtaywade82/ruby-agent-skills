# frozen_string_literal: true

require "digest"
require "openssl"
require "securerandom"

class AuthenticationService
  RESET_TTL_SECONDS = 900

  def initialize(users:, sessions:, reset_tokens:, clock: -> { Time.now })
    @users = users
    @sessions = sessions
    @reset_tokens = reset_tokens
    @clock = clock
  end

  def login(email:, password:, pre_auth_session:)
    user = @users.values.find { |candidate| candidate[:email] == email }
    return { status: :invalid } unless user && digest_matches?(password, user.fetch(:password_digest))

    session_id = rotate_session(pre_auth_session, user_id: user.fetch(:id))
    { status: :authenticated, session_id: session_id, user_id: user.fetch(:id) }
  end

  # Revocation is recorded rather than deleting the row, so a replayed id is
  # distinguishable from an unknown one.
  def logout(session_id:)
    session = @sessions[session_id]
    return { status: :logged_out } unless session

    session[:active] = false
    session[:revoked_at] = @clock.call
    { status: :logged_out }
  end

  # Same public status whether or not the email exists (no enumeration).
  def request_password_reset(email:)
    if @users.values.any? { |user| user[:email] == email }
      @reset_tokens[SecureRandom.urlsafe_base64(32)] = {
        email: email,
        expires_at: @clock.call + RESET_TTL_SECONDS,
        used: false
      }
    end
    { status: :accepted }
  end

  def redeem_password_reset(token:)
    reset = @reset_tokens[token]
    return :invalid unless reset && !reset[:used] && reset.fetch(:expires_at) > @clock.call

    reset[:used] = true
    :accepted
  end

  private

  # Fresh session identifier after authentication (session fixation defence);
  # the pre-authentication identifier is discarded.
  def rotate_session(pre_auth_session, user_id:)
    @sessions.delete(pre_auth_session)
    session_id = SecureRandom.urlsafe_base64(32)
    @sessions[session_id] = { user_id: user_id, authenticated_at: @clock.call, active: true, revoked_at: nil }
    session_id
  end

  def digest_matches?(candidate, password_digest)
    computed = Digest::SHA256.hexdigest(candidate.to_s)
    computed.bytesize == password_digest.bytesize &&
      OpenSSL.fixed_length_secure_compare(computed, password_digest)
  end
end
