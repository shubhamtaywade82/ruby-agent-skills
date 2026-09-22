# frozen_string_literal: true

require_relative "../app/jobs/sync_customer_job"

handlers = SyncCustomerJob.retry_handlers || []
discard_handlers = SyncCustomerJob.discard_handlers || []

abort "missing RemoteTimeout retry" unless handlers.any? { |exception, _| exception == RemoteTimeout }
abort "missing InvalidCustomerState discard" unless discard_handlers.any? { |exception, _| exception == InvalidCustomerState }
