# frozen_string_literal: true

class ApplicationJob
  class << self
    attr_accessor :enqueue_after_transaction_commit
  end
end

class PublishAccountJob < ApplicationJob
  def perform(account_id)
    account_id
  end
end
