# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class EventEnvelopeReferenceTest < Minitest::Test
  def test_reference_parses_envelopes_and_classifies_changes
    envelope = EventEnvelope.parse(
      "event_id" => "e-1",
      "event_type" => "order.placed",
      "schema_version" => 1,
      "occurred_at" => "2026-01-05T10:00:00Z",
      "producer" => "orders-api",
      "data" => {}
    )

    refute_nil envelope
    assert_equal "standard", envelope.field("loyalty_tier", default: "standard")
    refute EventEnvelope.breaking_change?([{ "type" => "add_optional", "field" => "region" }])
    assert EventEnvelope.breaking_change?([{ "type" => "rename", "field" => "amount", "to" => "total" }])
  end
end
