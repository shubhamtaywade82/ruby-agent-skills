# frozen_string_literal: true

require_relative "../app/jobs/rebuild_account_job"

options = RebuildAccountJob.concurrency_options || {}
abort "missing account concurrency key" unless options[:key]
abort "concurrency limit must be one" unless options[:to] == 1
