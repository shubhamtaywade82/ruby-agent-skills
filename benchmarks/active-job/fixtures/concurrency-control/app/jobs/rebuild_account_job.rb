# frozen_string_literal: true

class ApplicationJob
  class << self
    attr_reader :concurrency_options

    def limits_concurrency(**options)
      @concurrency_options = options
    end
  end
end

class RebuildAccountJob < ApplicationJob
  def perform(account_id)
    account_id
  end
end
