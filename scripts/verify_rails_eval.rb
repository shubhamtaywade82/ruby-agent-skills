#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "yaml"

ROOT = ENV.fetch("RUBY_AGENT_EVAL_ROOT")
EVAL_FILE = ENV.fetch("RUBY_AGENT_EVAL_FILE")
WORKSPACE = Dir.pwd

require File.join(ROOT, "lib", "ruby_agent_skills", "fixture_registry")
require File.join(ROOT, "lib", "ruby_agent_skills", "fixture_test_run")

evaluation = YAML.safe_load(File.read(EVAL_FILE, encoding: "UTF-8"), permitted_classes: [], aliases: false)
registry = YAML.safe_load(
  File.read(File.join(ROOT, "benchmarks/rails/fixtures.yml"), encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)
fixture = registry.fetch("fixtures").fetch(evaluation.fetch("id"))

def check(status, evidence = nil)
  result = { "status" => status }
  result["evidence"] = evidence if evidence
  result
end

# Last `limit` characters; String#[-n, n] returns nil for shorter strings.
def tail(text, limit)
  text.length > limit ? text[-limit..] : text
end

def changed_files
  stdout, = Open3.capture3("git", "status", "--short")
  stdout.lines.map { |line| line[3..] || line }.map(&:strip).reject(&:empty?)
end

source = Dir[File.join(WORKSPACE, "lib", "**", "*.rb")].sort.map do |path|
  File.read(path, encoding: "UTF-8")
end.join("
")
test_file = File.join(WORKSPACE, fixture.fetch("test_file"))
checks = {}

begin
  # Grade behaviour with the fixture's original test file; the workspace copy
  # is agent-editable and only counts toward the separate "tests" check.
  fixture_root = RubyAgentSkills::FixtureRegistry.new(
    root: ROOT, evaluation_set: "rails", fixture_root: "benchmarks/rails/fixtures"
  ).path(evaluation.fetch("id"))
  graded = RubyAgentSkills::FixtureTestRun.call(
    workspace: WORKSPACE, fixture_root: fixture_root, test_file: fixture.fetch("test_file")
  )

  checks["functional"] =
    graded.success? ? check("pass", "fixture contract tests passed") :
      check("fail", tail(graded.output, 4000))

  stdout, stderr, status = Open3.capture3(
    "ruby", "-Ilib", fixture.fetch("test_file"),
    chdir: WORKSPACE
  )
  test_source = File.file?(test_file) ? File.read(test_file, encoding: "UTF-8") : ""
  checks["tests"] =
    if test_source.match?(/Minitest|assert|refute|def test_/) && status.success?
      check("pass", graded.test_modified ? "workspace tests pass (extended from fixture tests)" : "workspace tests pass")
    else
      check("fail", "missing workspace tests or failing workspace test suite: #{tail(stdout + stderr, 2000)}")
    end

  required = Array(fixture["required_regex"])
  forbidden = Array(fixture["forbidden_regex"])
  contract = Array(fixture["contract_regex"])

  missing = required.reject { |expression| Regexp.new(expression).match?(source) }
  forbidden_found = forbidden.select { |expression| Regexp.new(expression).match?(source) }
  contract_missing = contract.reject { |expression| Regexp.new(expression).match?(source) }

  checks["contract"] =
    if missing.empty? && forbidden_found.empty? && contract_missing.empty?
      check("pass", "required boundary evidence present")
    else
      evidence = []
      evidence << "missing required: #{missing.join(", ")}" unless missing.empty?
      evidence << "forbidden present: #{forbidden_found.join(", ")}" unless forbidden_found.empty?
      evidence << "missing contract evidence: #{contract_missing.join(", ")}" unless contract_missing.empty?
      check("fail", evidence.join("; "))
    end
rescue StandardError => e
  checks["functional"] ||= check("fail", "verification raised #{e.class}: #{e.message}")
  checks["tests"] ||= check("fail", "verification raised #{e.class}: #{e.message}")
  checks["contract"] ||= check("fail", "verification raised #{e.class}: #{e.message}")
end

files = changed_files
allowed = ["lib/", "app/", "test/", "spec/", "config/", "db/"]
unexpected = files.reject { |path| allowed.any? { |prefix| path.start_with?(prefix) } }
checks["scope_control"] =
  unexpected.empty? ? check("pass") : check("fail", "unexpected files: #{unexpected.join(", ")}")

declared = evaluation.fetch("checks")
result = {
  "metadata" => {
    "verifier" => "scripts/verify_rails_eval.rb",
    "fixture" => fixture,
    "changed_files" => files
  },
  "checks" => checks.select { |name, _| declared.include?(name) }
}

File.write(
  ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"),
  JSON.pretty_generate(result) + "
",
  encoding: "UTF-8"
)

abort "verification failed" if result["checks"].values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
