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
  "error-boundary" => "app/controllers/orders_controller.rb",
  "request-correlation" => "config/application.rb",
  "instrumentation-event" => "app/services/order_checkout.rb",
  "health-semantics" => "config/routes.rb"
}.fetch(evaluation.fetch("id"))
source_path = File.join(workspace, implementation)
source = File.file?(source_path) ? File.read(source_path, encoding: "UTF-8") : ""

checks = {}
ruby_files = Dir.glob(File.join(workspace, "**/*.rb"))
syntax = ruby_files.map do |file|
  _out, err, status = Open3.capture3("ruby", "-c", file)
  status.success? ? nil : { "file" => file, "error" => err }
end.compact
checks["functional"] = syntax.empty? ?
  { "status" => "pass", "evidence" => "Ruby fixture files compile" } :
  { "status" => "fail", "evidence" => syntax }

case evaluation.fetch("id")
when "error-boundary"
  ok = source.match?(/InvalidOrderState/) &&
       source.match?(/409/) &&
       !source.match?(/rescue\s+StandardError/)
  checks["contract"] = source.match?(/OrdersController/) ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "OrdersController missing" }
  checks["functional"] = ok ?
    { "status" => "pass", "evidence" => "narrow 409 mapping detected without broad StandardError rescue" } :
    { "status" => "fail", "evidence" => "expected exception mapping contract not detected" }

when "request-correlation"
  request_id = source.match?(/request\.uuid|request\.request_id|request_id/)
  filter = source.match?(/Authorization|authorization|filter_parameters/)
  second_id = source.match?(/SecureRandom\.(uuid|hex)|UUID/) 
  checks["functional"] = request_id && filter && !second_id ?
    { "status" => "pass", "evidence" => "existing request correlation and sensitive-header filtering detected" } :
    { "status" => "fail", "evidence" => "request correlation/filtering contract not detected" }
  checks["contract"] = !second_id ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "second correlation identifier appears to be generated" }

when "instrumentation-event"
  event = source.match?(/ActiveSupport::Notifications\.instrument/)
  name = source.match?(/checkout\.completed/)
  payload = source.match?(/order_id/)
  checks["functional"] = event && name && payload ?
    { "status" => "pass", "evidence" => "stable event and minimal payload detected" } :
    { "status" => "fail", "evidence" => "instrumentation contract not detected" }
  checks["contract"] = !source.match?(/Notifications.*(save!|update!|destroy!|deliver|charge)/m) ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "instrumentation appears coupled to domain side effects" }

when "health-semantics"
  route = source.match?(/rails\/health#show/)
  dependency = source.match?(/Redis|redis|ExternalService|Database\.connection/)
  checks["functional"] = route && !dependency ?
    { "status" => "pass", "evidence" => "boot-health route preserved without dependency coupling" } :
    { "status" => "fail", "evidence" => "health semantics contract not detected" }
  checks["contract"] = route ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "built-in health route missing" }
end

test_files = Dir.glob(File.join(workspace, "{test,spec}/**/*.{rb}"))
if test_files.empty?
  checks["tests"] = { "status" => "fail", "evidence" => "no test/spec files found" }
else
  results = test_files.map do |file|
    out, err, status = Open3.capture3("ruby", file, chdir: workspace)
    { "file" => file, "status" => status.success? ? "pass" : "fail", "stdout" => out, "stderr" => err }
  end
  checks["tests"] = results.all? { |result| result["status"] == "pass" } ?
    { "status" => "pass", "evidence" => results } :
    { "status" => "fail", "evidence" => results }
end

changed_files = %x{git status --short}.lines.map { |line| (line[3..] || line).strip }.reject(&:empty?)
checks["scope_control"] = { "status" => "pass", "evidence" => "recorded #{changed_files.length} changed paths" }

checks.select! { |name, _| Array(evaluation.fetch("checks")).include?(name) }

result = {
  "metadata" => {
    "verifier" => "scripts/verify_observability_eval.rb",
    "evaluation" => evaluation.fetch("id"),
    "implementation_file" => implementation,
    "changed_files" => changed_files
  },
  "checks" => checks
}
File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.pretty_generate(result) + "\n", encoding: "UTF-8")
abort "verification failed" if checks.values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
