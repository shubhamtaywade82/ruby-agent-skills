# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class AuthenticationContractTest < Minitest::Test
  def setup
    @now = Time.new(2026, 1, 1, 12, 0, 0)
    @clock = -> { @now }
    @users = {
      1 => { id: 1, email: "user@example.test", password_digest: Digest::SHA256.hexdigest("secret") }
    }
    @sessions = { "pre-auth" => { user_id: nil, authenticated_at: nil } }
    @tokens = {}
    @service = AuthenticationService.new(
      users: @users,
      sessions: @sessions,
      reset_tokens: @tokens,
      clock: @clock
    )
  end

  def test_login_rotates_the_pre_authentication_session
    result = @service.login(email: "user@example.test", password: "secret", pre_auth_session: "pre-auth")

    assert_equal :authenticated, result[:status]
    refute_equal "pre-auth", result[:session_id]
    refute_nil @sessions[result[:session_id]]
  end

  def test_password_reset_is_single_use_and_expiring
    @service.request_password_reset(email: "user@example.test")
    token = @tokens.keys.first

    assert_equal :accepted, @service.redeem_password_reset(token: token)
    assert_equal :invalid, @service.redeem_password_reset(token: token)

    @service.request_password_reset(email: "user@example.test")
    expired_token = @tokens.keys.last
    @now += 901

    assert_equal :invalid, @service.redeem_password_reset(token: expired_token)
  end

  def test_unknown_and_known_reset_requests_have_same_public_status
    assert_equal(
      @service.request_password_reset(email: "user@example.test")[:status],
      @service.request_password_reset(email: "unknown@example.test")[:status]
    )
  end

  def test_logout_revokes_the_session
    result = @service.login(email: "user@example.test", password: "secret", pre_auth_session: "pre-auth")
    session_id = result[:session_id]

    @service.logout(session_id: session_id)

    assert_equal false, @sessions.fetch(session_id)[:active]
    assert @sessions.fetch(session_id)[:revoked_at]
  end
end
