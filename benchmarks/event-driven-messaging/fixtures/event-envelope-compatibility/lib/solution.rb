# frozen_string_literal: true

class EventEnvelope
  def self.parse(payload)
    nil
  end

  def field(name, default: nil)
    nil
  end

  def self.breaking_change?(changes)
    nil
  end
end

class EnvelopeConsumer
  def process(payload)
    nil
  end
end
