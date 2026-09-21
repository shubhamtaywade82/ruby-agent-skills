# frozen_string_literal: true

require_relative "../app/jobs/publish_account_job"

abort "job must enqueue after transaction commit" unless PublishAccountJob.enqueue_after_transaction_commit == true
