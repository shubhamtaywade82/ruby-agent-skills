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
  "boundary-selection" => "test/requests/orders_test.rb",
  "deterministic-job" => "test/jobs/notify_customer_job_test.rb",
  "parallel-safety" => "test/test_helper.rb",
  "flaky-diagnosis" => "test/models/order_test.rb",
  "system-contract" => "test/system/checkout_test.rb",
  "test-performance" => "test/test_helper.rb"
}.fetch(evaluation.fetch("id"))

source_path = File.join(workspace, implementation)
source = File.file?(source_path) ? File.read(source_path, encoding: "UTF-8") : ""
all_tests = Dir.glob(File.join(workspace, "test/**/*_test.rb"))
all_bodies = all_tests.map { |file| File.read(file, encoding: "UTF-8") }.join("
")
checks = {}

ruby_files = Dir.glob(File.join(workspace, "**/*.rb"))
syntax = ruby_files.filter_map do |file|
  _out, err, status = Open3.capture3("ruby", "-c", file)
  status.success? ? nil : { "file" => file, "error" => err }
end
checks["functional"] = syntax.empty? ?
  { "status" => "pass", "evidence" => "Ruby fixture files compile" } :
  { "status" => "fail", "evidence" => syntax }

case evaluation.fetch("id")
when "boundary-selection"
  request = all_bodies.match?(/ActionDispatch::IntegrationTest/)
  direct = all_bodies.match?(/OrdersController.*gets*:/m)
  checks["functional"] = request && !direct ?
    { "status" => "pass", "evidence" => "request/integration boundary detected" } :
    { "status" => "fail", "evidence" => "request boundary or direct-controller test detected" }
  checks["contract"] = all_bodies.match?(/assert_responses*:created/) && all_bodies.match?(/Order.exists?/) ?
    { "status" => "pass", "evidence" => "HTTP and persistence contract asserted" } :
    { "status" => "fail", "evidence" => "HTTP/persistence contract incomplete" }

when "deterministic-job"
  helper = all_bodies.include?("ActiveJob::TestHelper")
  perform = all_bodies.include?("perform_enqueued_jobs")
  enqueue = all_bodies.include?("assert_enqueued_with")
  sleep = all_bodies.match?(/sleeps*(/)
  checks["functional"] = helper && perform && enqueue && !sleep ?
    { "status" => "pass", "evidence" => "deterministic Active Job test boundary detected" } :
    { "status" => "fail", "evidence" => "job test contract incomplete or sleep detected" }
  checks["contract"] = !all_bodies.match?(/.new(.*).perform/m) || perform ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "direct perform bypasses relevant job boundary" }

when "parallel-safety"
  parallel = all_bodies.include?("parallelize")
  shared_global = all_bodies.match?(/^w+_STATEs*=s*[]/)
  hard_port = all_bodies.match?(/^TEST_PORTs*=s*3000$/)
  checks["functional"] = parallel && !shared_global && !hard_port ?
    { "status" => "pass", "evidence" => "parallel execution preserved with isolated resource/state" } :
    { "status" => "fail", "evidence" => "shared state/resource collision remains" }
  checks["contract"] = parallel ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "global parallelization was removed" }

when "flaky-diagnosis"
  sleep = all_bodies.match?(/sleeps*(/)
  retry_mask = all_bodies.match?(/rescue.*retry|retrys+if/m)
  global = all_bodies.match?(/^$w+s*=/)
  fixed_state = all_bodies.include?("ShippingContext") && all_bodies.include?("current = nil")
  checks["functional"] = fixed_state && !sleep && !retry_mask && !global ?
    { "status" => "pass", "evidence" => "shared-state leak addressed without sleep/retry masking" } :
    { "status" => "fail", "evidence" => "flaky-test workaround or shared state remains" }
  checks["contract"] = !retry_mask && !sleep ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "forbidden flaky workaround detected" }

when "system-contract"
  base = source.include?("ApplicationSystemTestCase")
  interaction = source.include?("click_on")
  visible = source.include?("assert_text")
  checks["functional"] = base && interaction && visible ?
    { "status" => "pass", "evidence" => "focused user journey system test detected" } :
    { "status" => "fail", "evidence" => "system-test contract incomplete" }
  checks["contract"] = !source.match?(/Order\.total|calculate_total|private_method/) ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "internal calculation coupled into system test" }

when "test-performance"
  helper_glob = source.match?(/Dir[Rails.root.join("test"/)
  deep_factory = source.include?("build_customer_with_all_associations")
  optimized_files = Dir.glob(File.join(workspace, "test/**/*_test.rb")).map { |file| File.read(file, encoding: "UTF-8") }
  optimized_bodies = optimized_files.join("
")
  still_expensive = optimized_bodies.match?(/Dir[Rails.root.join("test"/) || optimized_bodies.include?("build_customer_with_all_associations")
  assertions = optimized_bodies.include?("assert")
  checks["functional"] = !still_expensive && assertions ?
    { "status" => "pass", "evidence" => "measured setup sources removed while assertions remain" } :
    { "status" => "fail", "evidence" => "performance bottleneck remains or assertions were removed" }
  checks["contract"] = helper_glob || deep_factory ?
    { "status" => "fail", "evidence" => "fixture represents expensive baseline but verifier did not observe a scoped optimization" } :
    { "status" => "pass" }
end

test_files = Dir.glob(File.join(workspace, "test/**/*_test.rb"))
if test_files.empty?
  checks["tests"] = { "status" => "fail", "evidence" => "no Rails test files found" }
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
checks["performance"] = evaluation.fetch("id") == "test-performance" ?
  { "status" => "pass", "evidence" => "verifier checks for removal of targeted setup bottlenecks; runtime measurement belongs to external campaign runs" } :
  { "status" => "skipped" }

checks.select! { |name, _| Array(evaluation.fetch("checks")).include?(name) }

result = {
  "metadata" => {
    "verifier" => "scripts/verify_test_engineering_eval.rb",
    "evaluation" => evaluation.fetch("id"),
    "implementation_file" => implementation,
    "changed_files" => changed_files
  },
  "checks" => checks
}

File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.pretty_generate(result) + "
", encoding: "UTF-8")
abort "verification failed" if checks.values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
