# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class EventEnvelopeCompatibilityTest < Minitest::Test
  V1_PAYLOAD = {
    "event_id" => "evt-0001",
    "event_type" => "order.placed",
    "schema_version" => 1,
    "occurred_at" => "2026-01-05T10:00:00Z",
    "producer" => "orders-api",
    "correlation_id" => "corr-77",
    "causation_id" => "corr-77",
    "data" => { "order_id" => "o-1", "amount" => 2500 }
  }.freeze

  def test_v1_payload_without_optional_field_reads_with_default_semantics
    envelope = EventEnvelope.parse(V1_PAYLOAD)

    refute_nil envelope
    assert_equal 1, envelope.schema_version
    assert_equal "standard", envelope.field("loyalty_tier", default: "standard")
    assert_equal "o-1", envelope.field("order_id")
  end

  def test_v2_optional_field_is_backward_compatible
    payload = V1_PAYLOAD.merge(
      "schema_version" => 2,
      "data" => V1_PAYLOAD["data"].merge("loyalty_tier" => "gold")
    )
    envelope = EventEnvelope.parse(payload)

    refute_nil envelope
    assert_equal 2, envelope.schema_version
    assert_equal "gold", envelope.field("loyalty_tier", default: "standard")
    assert_equal "evt-0001", envelope.event_id
  end

  def test_unknown_optional_field_is_ignored
    payload = V1_PAYLOAD.merge("experiment_bucket" => "variant-b")
    envelope = EventEnvelope.parse(payload)
    consumer = EnvelopeConsumer.new

    refute_nil envelope
    assert_includes envelope.unknown_fields, "experiment_bucket"
    result = consumer.process(payload)

    assert_equal "processed", result.fetch("status")
    assert_equal "evt-0001", result.fetch("event_id")
  end

  def test_incompatible_change_requires_a_new_version
    rename = [{ "type" => "rename", "field" => "amount", "to" => "total" }]
    remove = [{ "type" => "remove", "field" => "amount" }]
    type_change = [{ "type" => "type_change", "field" => "amount", "from" => "integer", "to" => "string" }]
    add_required = [{ "type" => "add_required", "field" => "region" }]
    add_optional = [{ "type" => "add_optional", "field" => "region" }]

    assert EventEnvelope.breaking_change?(rename), "renaming a required field must not ship as additive"
    assert EventEnvelope.breaking_change?(remove)
    assert EventEnvelope.breaking_change?(type_change)
    assert EventEnvelope.breaking_change?(add_required)
    refute EventEnvelope.breaking_change?(add_optional), "optional fields are backward compatible"
  end

  def test_event_identity_is_stable_across_redelivery
    first = EventEnvelope.parse(V1_PAYLOAD)
    second = EventEnvelope.parse(V1_PAYLOAD)

    assert_equal first.event_id, second.event_id
    assert_equal first.dedup_key, second.dedup_key
    assert_equal "evt-0001:order.placed", first.dedup_key

    consumer = EnvelopeConsumer.new
    delivered_ids = [consumer.process(V1_PAYLOAD), consumer.process(V1_PAYLOAD)]
                     .map { |result| result.fetch("event_id") }.uniq

    assert_equal 1, delivered_ids.length, "redelivery must preserve event identity"
  end

  def test_payload_without_identity_is_rejected
    consumer = EnvelopeConsumer.new

    assert_nil EventEnvelope.parse(V1_PAYLOAD.merge("event_id" => ""))
    assert_nil EventEnvelope.parse(V1_PAYLOAD.reject { |key, _| key == "event_type" })
    assert_nil EventEnvelope.parse(V1_PAYLOAD.merge("schema_version" => 0))

    result = consumer.process(V1_PAYLOAD.merge("event_id" => ""))

    assert_equal "rejected", result.fetch("status")
    assert_equal "invalid_envelope", result.fetch("reason")
  end
end
