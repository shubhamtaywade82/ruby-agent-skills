# frozen_string_literal: true

require_relative "store"

module Schema
  def self.migrate(store); end
end

class PaymentWebhook
  def initialize(store:, secret:)
    @store = store
    @secret = secret
  end

  # Returns :processed, :ignored, or :rejected.
  def call(body:, signature:)
    nil
  end
end
