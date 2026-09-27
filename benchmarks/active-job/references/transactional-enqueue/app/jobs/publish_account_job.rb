# frozen_string_literal: true

class ApplicationJob
  class << self
    attr_accessor :enqueue_after_transaction_commit
  end
end

class PublishAccountJob < ApplicationJob
  # Enqueue only once the surrounding transaction commits; a rollback drops
  # the job instead of running it against rows that never existed.
  self.enqueue_after_transaction_commit = true

  def perform(account_id)
    account_id
  end
end
