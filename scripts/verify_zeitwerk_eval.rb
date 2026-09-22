#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = ENV.fetch("RUBY_AGENT_EVAL_ROOT")
EVAL_FILE = ENV.fetch("RUBY_AGENT_EVAL_FILE")
WORKSPACE = Dir.pwd

evaluation = YAML.safe_load(File.read(EVAL_FILE, encoding: "UTF-8"), permitted_classes: [], aliases: false)
registry = YAML.safe_load(
  File.read(File.join(ROOT, "benchmarks/zeitwerk/fixtures.yml"), encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)
fixture = registry.fetch("fixtures").fetch(evaluation.fetch("id"))
implementation = File.join(WORKSPACE, fixture.fetch("implementation_file"))
source = File.file?(implementation) ? File.read(implementation, encoding: "UTF-8") : ""

checks = {}

case evaluation.fetch("id")
when "path-constant-contract"
  expected = source.match?(/modules+Paymentss*
s*classs+Processor/)
  functional = begin
    require implementation
    defined?(Payments::Processor) && Payments::Processor.new.call == :ok
  rescue StandardError => e
    e
  end

  checks["functional"] =
    functional == true ? { "status" => "pass" } : { "status" => "fail", "evidence" => functional.inspect }

  checks["contract"] =
    expected ? { "status" => "pass", "evidence" => "payments/processor.rb defines Payments::Processor" } :
      { "status" => "fail", "evidence" => "expected namespace/constant mapping not detected" }

when "initializer-reload-boundary"
  checks["functional"] =
    source.match?(/config.to_prepare|reloader.to_prepare/) && !source.match?(/ApiGateway.endpoints*=.*
?s*z/) ?
      { "status" => "pass" } :
      { "status" => "fail", "evidence" => "reload-aware initializer boundary not detected" }

  checks["contract"] =
    source.match?(/to_prepare/) && !source.match?(/requires+["'].*api_gateway/) ?
      { "status" => "pass" } :
      { "status" => "fail", "evidence" => "initializer appears to eagerly require reloadable code or lacks to_prepare" }
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
    "verifier" => "scripts/verify_zeitwerk_eval.rb",
    "fixture" => fixture,
    "changed_files" => changed_files
  },
  "checks" => checks.select { |name, _| Array(evaluation.fetch("checks")).include?(name) }
}

File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.pretty_generate(result) + "
", encoding: "UTF-8")
abort "verification failed" if result["checks"].values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
