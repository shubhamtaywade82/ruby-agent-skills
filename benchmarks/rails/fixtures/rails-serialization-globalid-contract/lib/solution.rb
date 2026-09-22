# frozen_string_literal: true

require "base64"
require "openssl"

class ReportSerializer
  def serialize(report)
    {
      id: report[:id],
      name: report[:name],
      email: report[:email],
      password_hash: report[:password_hash]
    }
  end
end

class GlobalIdLocator
  def initialize(records:)
    @records = records
  end

  def locate(global_id)
    _, id = global_id.split(":", 2)
    @records.find { |record| record[:id].to_s == id }
  end
end

class SignedGlobalId
  def initialize(secret:, clock: -> { Time.now })
    @secret = secret
    @clock = clock
  end

  def create(id:, purpose:, expires_at:)
    payload = "#{purpose}|#{id}|#{expires_at.to_i}"
    Base64.urlsafe_encode64(payload)
  end

  def locate(token, purpose:)
    payload = Base64.urlsafe_decode64(token)
    _purpose, id, _expires_at = payload.split("|", 3)
    id
  end
end
