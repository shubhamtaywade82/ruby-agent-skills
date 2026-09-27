# frozen_string_literal: true

class ApplicationJob
  class << self
    attr_reader :retry_handlers, :discard_handlers

    def retry_on(exception, **options)
      @retry_handlers ||= []
      @retry_handlers << [exception, options]
    end

    def discard_on(exception, **options)
      @discard_handlers ||= []
      @discard_handlers << [exception, options]
    end
  end
end

class RemoteTimeout < StandardError; end
class InvalidCustomerState < StandardError; end

class SyncCustomerJob < ApplicationJob
  # Transient: bounded retries with growing backoff.
  retry_on RemoteTimeout, wait: :polynomially_longer, attempts: 5
  # Permanent: retrying cannot fix invalid state.
  discard_on InvalidCustomerState

  def perform(customer_id)
    customer_id
  end
end
