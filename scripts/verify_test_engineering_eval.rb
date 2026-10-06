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
  "test-performance" => "test/test_helper.rb",
  "rspec-request-contract" => "spec/requests/orders_spec.rb"
}.fetch(evaluation.fetch("id"))

source_path = File.join(workspace, implementation)
source = File.file?(source_path) ? File.read(source_path, encoding: "UTF-8") : ""
rspec = evaluation.fetch("id").start_with?("rspec-")
# RSpec shared examples and support live outside *_spec.rb files.
all_tests = Dir.glob(File.join(workspace, rspec ? "spec/**/*.rb" : "test/**/*_test.rb")).sort
test_bodies = all_tests.map { |file| File.read(file, encoding: "UTF-8") }
all_bodies = test_bodies.join("\n")
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
  # Per file, so unrelated files cannot combine into a false match.
  direct = test_bodies.any? { |body| body.match?(/OrdersController.*get\s*:/m) }
  checks["functional"] = request && !direct ?
    { "status" => "pass", "evidence" => "request/integration boundary detected" } :
    { "status" => "fail", "evidence" => "request boundary or direct-controller test detected" }
  checks["contract"] = all_bodies.match?(/assert_response\s*:created/) && all_bodies.match?(/Order\.exists\?/) ?
    { "status" => "pass", "evidence" => "HTTP and persistence contract asserted" } :
    { "status" => "fail", "evidence" => "HTTP/persistence contract incomplete" }

when "deterministic-job"
  helper = all_bodies.include?("ActiveJob::TestHelper")
  perform = all_bodies.include?("perform_enqueued_jobs")
  enqueue = all_bodies.include?("assert_enqueued_with")
  sleep = all_bodies.match?(/\bsleep\s*\(/)
  checks["functional"] = helper && perform && enqueue && !sleep ?
    { "status" => "pass", "evidence" => "deterministic Active Job test boundary detected" } :
    { "status" => "fail", "evidence" => "job test contract incomplete or sleep detected" }
  checks["contract"] = !all_bodies.match?(/\.new\(.*\)\.perform/m) || perform ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "direct perform bypasses relevant job boundary" }

when "parallel-safety"
  # The shared resources live in test/test_helper.rb, the implementation file.
  parallel = source.include?("parallelize")
  shared_global = source.match?(/^\w+_STATE\s*=\s*\[\]/)
  hard_port = source.match?(/^TEST_PORT\s*=\s*3000$/)
  checks["functional"] = parallel && !shared_global && !hard_port ?
    { "status" => "pass", "evidence" => "parallel execution preserved with isolated resource/state" } :
    { "status" => "fail", "evidence" => "shared state/resource collision remains" }
  checks["contract"] = parallel ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "global parallelization was removed" }

when "flaky-diagnosis"
  sleep = all_bodies.match?(/\bsleep\s*\(/)
  retry_mask = all_bodies.match?(/rescue.*\bretry\b|retry\s+if/m)
  global = all_bodies.match?(/^\$\w+\s*=/)
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
  helper_glob = source.match?(/Dir\[Rails\.root\.join\("test"/)
  deep_factory = source.include?("build_customer_with_all_associations")
  # The expensive setup lives in test/test_helper.rb (the implementation
  # file); the suite's assertions live in the *_test.rb files.
  still_expensive = helper_glob || deep_factory || all_bodies.include?("build_customer_with_all_associations")
  assertions = all_bodies.match?(/\bassert(_\w+)?\b/)
  checks["functional"] = !still_expensive && assertions ?
    { "status" => "pass", "evidence" => "measured setup sources removed while assertions remain" } :
    { "status" => "fail", "evidence" => "performance bottleneck remains or assertions were removed" }
  checks["contract"] = helper_glob || deep_factory ?
    { "status" => "fail", "evidence" => "fixture represents expensive baseline but verifier did not observe a scoped optimization" } :
    { "status" => "pass" }
when "rspec-request-contract"
  request = all_bodies.match?(/type:\s*:request/) || all_tests.any? { |file| file.include?("/spec/requests/") }
  controller_spec = all_bodies.match?(/type:\s*:controller|\bassigns\(/)
  non_block_mail = all_bodies.match?(/expect\([^)]*\)\s*\.(?:to|not_to|to_not)\s+have_enqueued_mail/)
  block_job = all_bodies.match?(/expect\s*\{.*?\}\s*\.to\s+have_enqueued_job\(FulfilOrderJob\)/m)
  block_mail = all_bodies.match?(/have_enqueued_mail\(OrderMailer,\s*:confirmation\)/) && !non_block_mail
  shared = all_bodies.match?(/shared_examples/) && all_bodies.match?(/(?:it_behaves_like|include_examples)/)
  checks["functional"] = request && !controller_spec && block_job && block_mail && shared ?
    { "status" => "pass", "evidence" => "request spec with block-form enqueue matchers and a shared 422 contract" } :
    { "status" => "fail", "evidence" => { "request_spec" => request, "controller_spec" => controller_spec, "block_job" => block_job, "block_mail" => block_mail, "shared_examples" => shared } }
  created = all_bodies.match?(/have_http_status\(\s*(?::created|201)\s*\)/)
  rejected = all_bodies.match?(/have_http_status\(\s*(?::unprocessable_content|:unprocessable_entity|422)\s*\)/)
  unpersisted = all_bodies.match?(/not_to\s*\(?\s*change\s*\(?\s*Order\s*,\s*:count/)
  checks["contract"] = created && rejected && unpersisted ?
    { "status" => "pass", "evidence" => "201, 422, and unchanged Order count asserted at the HTTP boundary" } :
    { "status" => "fail", "evidence" => { "created" => created, "rejected" => rejected, "unpersisted" => unpersisted } }
end

# These fixtures contain test code only, with no Rails application, so the
# tests cannot be executed here. The check is static: every Ruby file under
# test/ must parse and at least one test file must assert something.
# Behavioural judgement comes from the evaluation-specific checks above.
test_ruby = Dir.glob(File.join(workspace, rspec ? "spec/**/*.rb" : "test/**/*.rb")).sort
unparseable = test_ruby.reject { |file| Open3.capture3("ruby", "-c", file).last.success? }
asserting = test_bodies.any? { |body| body.match?(rspec ? /\bexpect\s*[({]/ : /\bassert(_\w+)?\b/) }
checks["tests"] =
  if unparseable.empty? && asserting
    { "status" => "pass", "evidence" => "test files parse and contain assertions (static: Rails runtime not provisioned)" }
  else
    { "status" => "fail", "evidence" => { "unparseable" => unparseable.map { |f| f.delete_prefix("#{workspace}/") }, "assertions_present" => asserting } }
  end

forbidden = all_bodies.match?(/allow_any_instance_of|expect_any_instance_of|\bsleep\s*\(/)
if rspec && forbidden
  checks["scope_control"] = { "status" => "fail", "evidence" => "any_instance stubbing or sleep detected" }
end

# Every test-engineering contract is satisfied inside the test suite, so a
# change outside test/ or spec/ (application code, config, stray files) is a
# scope violation. Renames report "old -> new"; the new path is what counts.
changed_files = %x{git status --short}.lines.map { |line| (line[3..] || line).strip.split(" -> ").last }
                                      .reject(&:empty?)
out_of_scope = changed_files.reject { |path| path.delete_prefix('"').start_with?("test/", "spec/") }
checks["scope_control"] ||=
  if out_of_scope.empty?
    { "status" => "pass", "evidence" => "#{changed_files.length} changed paths, all under test/ or spec/" }
  else
    { "status" => "fail", "evidence" => { "outside_test_suite" => out_of_scope } }
  end
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

File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.pretty_generate(result) + "\n", encoding: "UTF-8")
abort "verification failed" if checks.values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
