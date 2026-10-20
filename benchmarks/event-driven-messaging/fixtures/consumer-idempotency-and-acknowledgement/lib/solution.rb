# frozen_string_literal: true

class DeduplicationStore
  def reserve!(message_id)
    nil
  end

  def include?(message_id)
    nil
  end

  def release!(message_id)
    nil
  end
end

class IdempotentConsumer
  def initialize(store:, handler:)
    @store = store
    @handler = handler
  end

  def consume(message)
    nil
  end
end

class EffectsRecorder
  def initialize
  end

  def call(message)
    nil
  end
end
