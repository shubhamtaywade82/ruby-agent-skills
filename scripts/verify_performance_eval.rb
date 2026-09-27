#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = ENV.fetch("RUBY_AGENT_EVAL_ROOT")
EVAL_FILE = ENV.fetch("RUBY_AGENT_EVAL_FILE")
WORKSPACE = Dir.pwd

evaluation = YAML.safe_load(File.read(EVAL_FILE, encoding: "UTF-8"), permitted_classes: [], aliases: false)
registry = YAML.safe_load(File.read(File.join(ROOT, "benchmarks/performance/fixtures.yml"), encoding: "UTF-8"), permitted_classes: [], aliases: false)
fixture = registry.fetch("fixtures").fetch(evaluation.fetch("id"))
implementation = File.join(WORKSPACE, fixture.fetch("implementation_file"))
source = File.file?(implementation) ? File.read(implementation, encoding: "UTF-8") : ""

checks = {}

begin
  require implementation

  case evaluation.fetch("id")
  when "performance-allocation-boundary"
    events = Array.new(1000) { |i| { label: i.to_s } }
    result = EventLabels.labels(events)
    checks["functional"] =
      result.length == 1000 && result.first == "0" && result.last == "999" ?
        { "status" => "pass" } :
        { "status" => "fail", "evidence" => result[0, 2].inspect }

    checks["contract"] =
      source.match?(/def\s+self\.labels\(events\)/) ?
        { "status" => "pass" } :
        { "status" => "fail", "evidence" => "public API missing" }

    checks["performance"] =
      !source.match?(/\.map\s*\{[^}]*\}\s*\.map/) && !source.match?(/\.map\s*\{[^}]*\}\s*\.select/) ?
        { "status" => "pass", "evidence" => "no obvious chained intermediate collection in implementation" } :
        { "status" => "fail", "evidence" => "multiple collection transformations detected" }
  when "cache-key-boundary"
    a = DashboardCache.key(1, 9)
    b = DashboardCache.key(1, 9)
    c = DashboardCache.key(2, 9)
    checks["functional"] =
      a == b && a != c ?
        { "status" => "pass" } :
        { "status" => "fail", "evidence" => [a, b, c].inspect }

    checks["contract"] =
      source.match?(/def\s+self\.key\(tenant_id,\s*dashboard_id\)/) ?
        { "status" => "pass" } :
        { "status" => "fail", "evidence" => "public cache-key API missing" }

    checks["performance"] =
      !source.match?(/\b(ActiveRecord|Net::HTTP|Faraday|HTTParty|Redis\.new)\b/) ?
        { "status" => "pass", "evidence" => "key generation has no obvious database/network dependency" } :
        { "status" => "fail", "evidence" => "cache key appears to perform external work" }
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
    "verifier" => "scripts/verify_performance_eval.rb",
    "fixture" => fixture,
    "changed_files" => changed_files
  },
  "checks" => checks.select { |name, _| Array(evaluation.fetch("checks")).include?(name) }
}

File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.pretty_generate(result) + "\n", encoding: "UTF-8")
abort "verification failed" if result["checks"].values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
