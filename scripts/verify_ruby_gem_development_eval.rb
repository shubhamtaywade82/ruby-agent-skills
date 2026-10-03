#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "yaml"

ROOT = ENV.fetch("RUBY_AGENT_EVAL_ROOT")
EVAL_FILE = ENV.fetch("RUBY_AGENT_EVAL_FILE")
WORKSPACE = Dir.pwd

evaluation = YAML.safe_load(
  File.read(EVAL_FILE, encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)
registry = YAML.safe_load(
  File.read(
    File.join(ROOT, "benchmarks", "ruby-gem-development", "fixtures.yml"),
    encoding: "UTF-8"
  ),
  permitted_classes: [],
  aliases: false
)
fixture = registry.fetch("fixtures").fetch(evaluation.fetch("id"))
implementation = File.join(WORKSPACE, fixture.fetch("implementation_file"))
source = File.file?(implementation) ? File.read(implementation, encoding: "UTF-8") : ""

def check(status, evidence = nil)
  result = { "status" => status }
  result["evidence"] = evidence if evidence
  result
end

def changed_files
  stdout, = Open3.capture3("git", "status", "--short")
  stdout.lines.map { |line| line[3..] || line }.map(&:strip).reject(&:empty?)
end

checks = {}
begin
  require File.join(ROOT, "lib", "ruby_agent_skills", "fixture_test_run")
  graded = RubyAgentSkills::FixtureTestRun.call(
    workspace: WORKSPACE,
    fixture_root: File.join(
      ROOT, "benchmarks", "ruby-gem-development", "fixtures",
      evaluation.fetch("id")
    ),
    test_file: fixture.fetch("test_file")
  )
  checks["functional"] =
    graded.success? ? check("pass", "fixture contract tests passed") :
      check("fail", graded.output[-4000..] || "")
rescue StandardError => e
  checks["functional"] = check("fail", "#{e.class}: #{e.message}")
end

files = changed_files
test_file = File.join(WORKSPACE, fixture.fetch("test_file"))
stdout, stderr, status = Open3.capture3(
  "ruby", test_file, chdir: WORKSPACE
)
test_source = File.file?(test_file) ? File.read(test_file, encoding: "UTF-8") : ""
checks["tests"] =
  if test_source.match?(/Minitest|assert|refute|def test_/) && status.success?
    check("pass", "workspace tests pass")
  else
    check(
      "fail",
      "missing workspace tests or failing test suite: #{(stdout + stderr)[-2000..] || ""}"
    )
  end

required = Array(fixture.fetch("required_regex"))
forbidden = Array(fixture.fetch("forbidden_regex"))
contract = Array(fixture.fetch("contract_regex"))
missing = required.reject { |expression| Regexp.new(expression).match?(source) }
forbidden_found = forbidden.select { |expression| Regexp.new(expression).match?(source) }
contract_missing = contract.reject { |expression| Regexp.new(expression).match?(source) }

checks["contract"] =
  if missing.empty? && forbidden_found.empty? && contract_missing.empty?
    check(
      "pass",
      [
        "gem skeleton and package contract",
        "dependency grouping and consumer require path",
        "package boundary and release authorization"
      ].join("; ")
    )
  else
    check(
      "fail",
      [
        ("missing required: #{missing.join(", ")}" unless missing.empty?),
        ("forbidden present: #{forbidden_found.join(", ")}" unless forbidden_found.empty?),
        ("missing contract evidence: #{contract_missing.join(", ")}" unless contract_missing.empty?)
      ].compact.join("; ")
    )
  end

allowed = ["lib/", "app/", "config/", "test/", "spec/", "Gemfile", "gemspec"]
unexpected = files.reject do |path|
  allowed.any? { |prefix| path.start_with?(prefix) }
end
checks["scope_control"] =
  if unexpected.empty?
    check("pass")
  else
    check("fail", "unexpected files: #{unexpected.join(", ")}")
  end

declared = evaluation.fetch("checks")
result = {
  "metadata" => {
    "verifier" => "scripts/verify_ruby_gem_development_eval.rb",
    "fixture" => fixture,
    "changed_files" => files
  },
  "checks" => checks.select { |name, _| declared.include?(name) }
}
File.write(
  ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"),
  "#{JSON.pretty_generate(result)}\n",
  encoding: "UTF-8"
)
abort "verification failed" if result["checks"].values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
