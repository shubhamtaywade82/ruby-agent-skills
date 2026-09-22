# frozen_string_literal: true

class EventLabels
  def self.labels(events)
    events.map { |event| event.fetch(:label) }
  end
end
