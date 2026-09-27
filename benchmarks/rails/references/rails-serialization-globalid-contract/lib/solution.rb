# frozen_string_literal: true

require "base64"
require "openssl"

class ReportSerializer
  PUBLIC_FIELDS = %i[id name].freeze

  # Explicit allowlist: new model attributes are never exposed by default.
  def serialize(report)
    report.slice(*PUBLIC_FIELDS)
  end
end

class GlobalIdLocator
  ALLOWED_MODELS = %w[Report].freeze

  def initialize(records:)
    @records = records
  end

  # Only allowed model names resolve; identity is not authorization, so
  # callers still authorize the located record.
  def locate(global_id)
    model, id = global_id.to_s.split(":", 2)
    return nil unless ALLOWED_MODELS.include?(model) && id

    @records.find { |record| record[:id].to_s == id }
  end
end

class SignedGlobalId
  SEPARATOR = "--"

  def initialize(secret:, clock: -> { Time.now })
    @secret = secret
    @clock = clock
  end

  # Token = base64(purpose|id|expires_at) + "--" + HMAC-SHA256 of that body.
  def create(id:, purpose:, expires_at:)
    body = Base64.urlsafe_encode64("#{purpose}|#{id}|#{expires_at.to_i}", padding: false)
    "#{body}#{SEPARATOR}#{signature(body)}"
  end

  def locate(token, purpose:)
    body, provided = token.to_s.split(SEPARATOR, 2)
    return nil unless body && provided && valid_signature?(body, provided)

    token_purpose, id, expires_at = Base64.urlsafe_decode64(body).split("|", 3)
    return nil unless token_purpose == purpose
    return nil unless expires_at.to_i > @clock.call.to_i

    id
  rescue ArgumentError
    nil
  end

  private

  def signature(body)
    OpenSSL::HMAC.hexdigest("SHA256", @secret, body)
  end

  def valid_signature?(body, provided)
    expected = signature(body)
    expected.bytesize == provided.bytesize && OpenSSL.fixed_length_secure_compare(expected, provided)
  end
end
