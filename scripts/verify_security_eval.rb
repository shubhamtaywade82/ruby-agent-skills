#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = ENV.fetch("RUBY_AGENT_EVAL_ROOT")
EVAL_FILE = ENV.fetch("RUBY_AGENT_EVAL_FILE")
WORKSPACE = Dir.pwd

evaluation = YAML.safe_load(
  File.read(EVAL_FILE, encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)
fixture_registry = YAML.safe_load(
  File.read(File.join(ROOT, "benchmarks/security/fixtures.yml"), encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)
fixture = fixture_registry.fetch("fixtures").fetch(evaluation.fetch("id"))

checks = {}
implementation = File.join(WORKSPACE, fixture.fetch("implementation_file"))
source = File.file?(implementation) ? File.read(implementation, encoding: "UTF-8") : ""

begin
  require implementation

  case evaluation.fetch("id")
  when "parameterized-query-boundary"
    relation = Object.new
    captured = nil
    relation.define_singleton_method(:where) do |*args|
      captured = args
      self
    end

    UserSearch.call("alice", relation: relation)
    safe_contract = captured == ["name ILIKE ?", "%alice%"]
    forbidden = source.match?(/"\#\{.*term.*\}"/) && !source.match?(/\?/)
    checks["functional"] = safe_contract ? { "status" => "pass" } : { "status" => "fail", "evidence" => captured.inspect }
    checks["contract"] = source.match?(/where\(.*\?.*term/) ? { "status" => "pass" } : { "status" => "fail", "evidence" => "parameterized where contract missing" }
    checks["functional"] = { "status" => "fail", "evidence" => "unsafe interpolation detected" } if forbidden
  when "authorization-boundary"
    user_class = Struct.new(:id, :admin) do
      def admin?
        admin
      end
    end
    document_class = Struct.new(:owner_id)
    document = document_class.new(1)

    owner = DocumentPolicy.new(user_class.new(1, false), document).update?
    admin = DocumentPolicy.new(user_class.new(2, true), document).update?
    unrelated = DocumentPolicy.new(user_class.new(2, false), document).update?

    checks["functional"] =
      owner && admin && !unrelated ?
        { "status" => "pass" } :
        { "status" => "fail", "evidence" => [owner, admin, unrelated].inspect }

    checks["contract"] =
      source.match?(/def\s+update\?/) && source.match?(/admin\?|owner_id/) ?
        { "status" => "pass" } :
        { "status" => "fail", "evidence" => "authorization boundary not explicit" }
  end
rescue StandardError => e
  checks["functional"] = { "status" => "fail", "evidence" => "#{e.class}: #{e.message}" }
  checks["contract"] ||= { "status" => "not_evaluated" }
end

case evaluation.fetch("id")
when "parameterized-query-boundary"
  checks["security"] = if source.match?(/where\(.*\?.*term/) && !source.match?(/where\s*\([^)]*#\{\s*term/)
    { "status" => "pass", "evidence" => "parameterized query boundary detected" }
  else
    { "status" => "fail", "evidence" => "untrusted query term is not clearly parameterized" }
  end
when "authorization-boundary"
  checks["security"] = if source.match?(/admin\?/) && source.match?(/owner_id/) && source.match?(/def\s+update\?/)
    { "status" => "pass", "evidence" => "authorization policy boundary is explicit" }
  else
    { "status" => "fail", "evidence" => "explicit authorization boundary not detected" }
  end
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
    "verifier" => "scripts/verify_security_eval.rb",
    "fixture" => fixture,
    "changed_files" => changed_files
  },
  "checks" => checks.select { |name, _| Array(evaluation.fetch("checks")).include?(name) }
}

File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.pretty_generate(result) + "\n", encoding: "UTF-8")
abort "verification failed" if result["checks"].values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
