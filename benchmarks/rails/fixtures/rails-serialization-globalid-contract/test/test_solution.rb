# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class SerializationGlobalIdContractTest < Minitest::Test
  def setup
    @clock = -> { Time.new(2026, 1, 1, 12, 0, 0) }
    @records = [
      { id: 1, name: "Visible", email: "visible@example.test", password_hash: "private", tenant_id: 10 },
      { id: 2, name: "Other", email: "other@example.test", password_hash: "private", tenant_id: 11 }
    ]
  end

  def test_serializer_allowlists_public_fields
    payload = ReportSerializer.new.serialize(@records.first)

    assert_equal({ id: 1, name: "Visible" }, payload)
  end

  def test_global_id_locator_is_allowlisted_and_returns_nil_for_missing
    locator = GlobalIdLocator.new(records: @records)

    assert_equal @records.first, locator.locate("Report:1")
    assert_nil locator.locate("User:1")
    assert_nil locator.locate("Report:999")
  end

  def test_signed_global_id_rejects_tampering
    signer = SignedGlobalId.new(secret: "secret", clock: @clock)
    token = signer.create(id: 1, purpose: "download", expires_at: @clock.call + 60)

    assert_equal "1", signer.locate(token, purpose: "download")

    tampered = token.dup
    tampered[-1] = tampered[-1] == "A" ? "B" : "A"
    assert_nil signer.locate(tampered, purpose: "download")
  end

  def test_signed_global_id_checks_purpose_and_expiry
    signer = SignedGlobalId.new(secret: "secret", clock: @clock)
    token = signer.create(id: 1, purpose: "download", expires_at: @clock.call + 60)

    assert_nil signer.locate(token, purpose: "admin")

    expired = signer.create(id: 1, purpose: "download", expires_at: @clock.call - 1)
    assert_nil signer.locate(expired, purpose: "download")
  end
end
