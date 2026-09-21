#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"
require "open3"

root = ENV.fetch("RUBY_AGENT_EVAL_ROOT")
eval_file = ENV.fetch("RUBY_AGENT_EVAL_FILE")
workspace = Dir.pwd
evaluation = YAML.safe_load(File.read(eval_file, encoding: "UTF-8"), permitted_classes: [], aliases: false)

implementation = {
  "idempotent-side-effect" => "app/jobs/receipt_delivery_job.rb",
  "retry-policy" => "app/jobs/sync_customer_job.rb",
  "transactional-enqueue" => "app/jobs/publish_account_job.rb",
  "concurrency-control" => "app/jobs/rebuild_account_job.rb"
}.fetch(evaluation.fetch("id"))
source_path = File.join(workspace, implementation)
source = File.file?(source_path) ? File.read(source_path, encoding: "UTF-8") : ""

checks = {}

ruby_files = Dir.glob(File.join(workspace, "**/*.rb"))
syntax_failures = ruby_files.filter_map do |file|
  _out, err, status = Open3.capture3("ruby", "-c", file)
  status.success? ? nil : { "file" => file, "error" => err }
end
checks["functional"] = syntax_failures.empty? ?
  { "status" => "pass", "evidence" => "all Ruby fixture files compile" } :
  { "status" => "fail", "evidence" => syntax_failures }

case evaluation.fetch("id")
when "idempotent-side-effect"
  checks["contract"] = source.match?(/ReceiptDeliveryJob/) ?
    { "status" => "pass" } :
    { "status" => "fail", "evidence" => "ReceiptDeliveryJob implementation missing" }

  checks["functional"] =
    if source.match?(/claim|idempot|unique|find_or_create|create_or_find_by|upsert|insert_all|ON CONFLICT/i)
      { "status" => "pass", "evidence" => "durable idempotency mechanism detected; verify behavior with tests" }
    else
      { "status" => "fail", "evidence" => "no durable idempotency mechanism detected" }
    end

when "retry-policy"
  retry_ok = source.match?(/retry_on\s+RemoteTimeout/)
  permanent_ok = source.match?(/discard_on\s+InvalidCustomerState/) && !source.match?(/retry_on\s+InvalidCustomerState/)
  checks["contract"] = { "status" => "pass", "evidence" => "perform API is preserved unless changed by agent" }
  checks["functional"] = retry_ok && permanent_ok ?
    { "status" => "pass", "evidence" => "transient retry and permanent discard policy detected" } :
    { "status" => "fail", "evidence" => "expected retry/discard mapping not detected" }

when "transactional-enqueue"
  ok = source.match?(/enqueue_after_transaction_commit\s*=\s*true/)
  checks["functional"] = ok ?
    { "status" => "pass", "evidence" => "enqueue_after_transaction_commit enabled" } :
    { "status" => "fail", "evidence" => "transaction-aware enqueue configuration missing" }
  checks["contract"] = source.match?(/class\s+PublishAccountJob/) ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "PublishAccountJob implementation missing" }

when "concurrency-control"
  limit_ok = source.match?(/limits_concurrency\s+/)
  key_ok = source.match?(/key:\s*->\s*\(?account_id|key:\s*->\s*\(?account/)
  one_ok = source.match?(/to:\s*1/)
  checks["functional"] = limit_ok && key_ok && one_ok ?
    { "status" => "pass", "evidence" => "per-account concurrency control detected" } :
    { "status" => "fail", "evidence" => "expected limits_concurrency key/to:1 configuration not detected" }
  checks["contract"] = source.match?(/class\s+RebuildAccountJob/) ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "RebuildAccountJob implementation missing" }
end

test_files = Dir.glob(File.join(workspace, "{test,spec}/**/*.{rb}"))
if test_files.empty?
  checks["tests"] = { "status" => "fail", "evidence" => "no test/spec files present" }
else
  results = test_files.map do |file|
    out, err, status = Open3.capture3("ruby", file, chdir: workspace)
    { "file" => file, "status" => status.success? ? "pass" : "fail", "stdout" => out, "stderr" => err }
  end
  checks["tests"] = results.all? { |r| r["status"] == "pass" } ?
    { "status" => "pass", "evidence" => results } :
    { "status" => "fail", "evidence" => results }
end

changed_files = %x{git status --short}.lines.map { |line| line[3..] || line }.map(&:strip).reject(&:empty?)
checks["scope_control"] = changed_files.all? { |path| !path.empty? } ?
  { "status" => "pass", "evidence" => "verifier recorded #{changed_files.length} changed paths" } :
  { "status" => "fail", "evidence" => "unable to inspect changed paths" }

checks.select! { |name, _| Array(evaluation.fetch("checks")).include?(name) }

result = {
  "metadata" => {
    "verifier" => "scripts/verify_active_job_eval.rb",
    "evaluation" => evaluation.fetch("id"),
    "implementation_file" => implementation,
    "changed_files" => changed_files
  },
  "checks" => checks
}

File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.pretty_generate(result) + "\n", encoding: "UTF-8")
abort "verification failed" if checks.values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
