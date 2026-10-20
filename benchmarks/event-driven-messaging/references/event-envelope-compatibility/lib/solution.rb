# frozen_string_literal: true

# Versioned event envelope with stable identity, explicit schema versioning,
# and backward-compatible optional-field evolution. Unknown optional fields
# are retained but never rejected, and breaking changes are classified as
# requiring a new envelope version instead of shipping as additive updates.
class EventEnvelope
  IDENTITY_FIELDS = %w[event_id event_type schema_version occurred_at producer].freeze
  KNOWN_FIELDS =
    (%w[event_id event_type schema_version occurred_at producer correlation_id causation_id data]).freeze
  BREAKING_CHANGE_TYPES = %w[rename remove type_change add_required].freeze

  attr_reader :event_id, :event_type, :schema_version, :occurred_at, :producer,
              :correlation_id, :causation_id, :data, :unknown_fields

  def initialize(event_id:, event_type:, schema_version:, occurred_at:, producer:,
                 correlation_id: nil, causation_id: nil, data: {}, unknown_fields: [])
    @event_id = event_id
    @event_type = event_type
    @schema_version = schema_version
    @occurred_at = occurred_at
    @producer = producer
    @correlation_id = correlation_id
    @causation_id = causation_id
    @data = data
    @unknown_fields = unknown_fields
  end

  def self.parse(payload)
    return nil unless payload.is_a?(Hash)

    IDENTITY_FIELDS.each do |field|
      value = payload[field]
      return nil if value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end

    version = payload.fetch("schema_version")
    return nil unless version.is_a?(Integer) && version >= 1

    new(
      event_id: payload.fetch("event_id"),
      event_type: payload.fetch("event_type"),
      schema_version: version,
      occurred_at: payload.fetch("occurred_at"),
      producer: payload.fetch("producer"),
      correlation_id: payload["correlation_id"],
      causation_id: payload["causation_id"],
      data: payload.fetch("data", {}),
      unknown_fields: payload.keys - KNOWN_FIELDS
    )
  end

  # Reads a payload field with documented default semantics, so a version-1
  # payload without an optional field stays readable by newer consumers.
  def field(name, default: nil)
    value = @data[name]

    value.nil? ? default : value
  end

  def dedup_key
    "#{@event_id}:#{@event_type}"
  end

  def self.breaking_change?(changes)
    Array(changes).any? { |change| BREAKING_CHANGE_TYPES.include?(change["type"]) }
  end
end

class EnvelopeConsumer
  def process(payload)
    envelope = EventEnvelope.parse(payload)

    return { "status" => "rejected", "reason" => "invalid_envelope" } if envelope.nil?

    {
      "status" => "processed",
      "event_id" => envelope.event_id,
      "schema_version" => envelope.schema_version
    }
  end
end
