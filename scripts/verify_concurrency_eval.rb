#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = ENV.fetch("RUBY_AGENT_EVAL_ROOT")
EVAL_FILE = ENV.fetch("RUBY_AGENT_EVAL_FILE")
WORKSPACE = Dir.pwd

evaluation = YAML.safe_load(File.read(EVAL_FILE, encoding: "UTF-8"), permitted_classes: [], aliases: false)
fixture_registry = YAML.safe_load(
  File.read(File.join(ROOT, "benchmarks/concurrency/fixtures.yml"), encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)
fixture = fixture_registry.fetch("fixtures").fetch(evaluation.fetch("id"))
implementation = File.join(WORKSPACE, fixture.fetch("implementation_file"))
source = File.file?(implementation) ? File.read(implementation, encoding: "UTF-8") : ""

checks = {}

begin
  require implementation
  counter = Counter.new
  threads = Array.new(20) { Thread.new { 100.times { counter.increment } } }
  threads.each(&:join)
  checks["functional"] = counter.value == 2000 ? { "status" => "pass" } : { "status" => "fail", "evidence" => counter.value.inspect }

  checks["contract"] =
    if source.match?(/Mutex|Monitor/) && source.match?(/synchronize/)
      { "status" => "pass", "evidence" => "shared state is explicitly synchronized" }
    else
      { "status" => "fail", "evidence" => "no explicit synchronization primitive found" }
    end
rescue StandardError => e
  checks["functional"] = { "status" => "fail", "evidence" => "#{e.class}: #{e.message}" }
  checks["contract"] ||= { "status" => "not_evaluated" }
end

changed_files = %x{git status --short}.lines.map { |line| line[3..] || line }.map(&:strip).reject(&:empty?)
checks["tests"] =
  if changed_files.any? { |path| path.start_with?("test/", "spec/") }
    { "status" => "pass", "evidence" => "agent changed a test/spec file" }
  else
    { "status" => "fail", "evidence" => "no test/spec changes detected" }
  end

result = {
  "metadata" => {
    "verifier" => "scripts/verify_concurrency_eval.rb",
    "fixture" => fixture,
    "changed_files" => changed_files
  },
  "checks" => checks.select { |name, _| Array(evaluation.fetch("checks")).include?(name) }
}

File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.pretty_generate(result) + "\n", encoding: "UTF-8")
abort "verification failed" if result["checks"].values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
