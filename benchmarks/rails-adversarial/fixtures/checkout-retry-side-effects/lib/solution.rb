# frozen_string_literal: true

require_relative "store"
require_relative "services"

module Schema
  def self.migrate(store); end
end

class Checkout
  def initialize(store:, gateway:, mailer:)
    @store = store
    @gateway = gateway
    @mailer = mailer
  end

  # Returns the order row.
  def call(cart_id:, request_id:)
    nil
  end
end
