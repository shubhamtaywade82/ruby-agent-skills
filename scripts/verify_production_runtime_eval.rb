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
  "puma-capacity" => "config/puma.rb",
  "graceful-shutdown" => "bin/entrypoint",
  "zero-downtime-release" => "docs/release.md",
  "config-contract" => "config/production.rb",
  "migration-gate" => "docs/release-migrations.md"
}.fetch(evaluation.fetch("id"))

source_path = File.join(workspace, implementation)
source = File.file?(source_path) ? File.read(source_path, encoding: "UTF-8") : ""
checks = {}

ruby_files = Dir.glob(File.join(workspace, "**/*.rb"))
syntax = ruby_files.filter_map do |file|
  _out, err, status = Open3.capture3("ruby", "-c", file)
  status.success? ? nil : { "file" => file, "error" => err }
end
checks["functional"] = syntax.empty? ?
  { "status" => "pass", "evidence" => "Ruby files compile" } :
  { "status" => "fail", "evidence" => syntax }

case evaluation.fetch("id")
when "puma-capacity"
  # Budget from the prompt: 4 CPU cores, database pool of 12 per process.
  # Each Puma thread can hold a connection, so default threads per process
  # must not exceed the pool, and default workers must not exceed cores.
  workers = source.match?(/workers\b/)
  threads = source.match?(/threads\b/)
  port = source.match?(/PORT/)
  worker_default = source[/ENV\.fetch\(\s*"WEB_CONCURRENCY"\s*,\s*"(\d+)"\s*\)/, 1]&.to_i
  thread_default = source[/ENV\.fetch\(\s*"RAILS_MAX_THREADS"\s*,\s*"(\d+)"\s*\)/, 1]&.to_i
  within_budget = worker_default && thread_default && worker_default.between?(1, 4) && thread_default.between?(1, 12)
  checks["functional"] = workers && threads && port && within_budget ?
    { "status" => "pass", "evidence" => "workers=#{worker_default} threads=#{thread_default} within 4 cores / pool 12" } :
    { "status" => "fail", "evidence" => "Puma capacity contract incomplete or over budget (workers=#{worker_default.inspect}, threads=#{thread_default.inspect}; need workers <= 4, threads <= 12)" }
  checks["contract"] = source.match?(/preload_app!/) ?
    { "status" => "pass", "evidence" => "preload policy preserved" } :
    { "status" => "fail", "evidence" => "preload policy changed" }

when "graceful-shutdown"
  term = source.match?(/TERM/)
  forward = source.match?(/kill\s+-TERM/)
  wait = source.match?(/wait/)
  checks["functional"] = term && forward && wait ?
    { "status" => "pass", "evidence" => "termination signal forwarding and wait detected" } :
    { "status" => "fail", "evidence" => "graceful shutdown contract incomplete" }
  # Backgrounding Puma and waiting is the forwarding pattern; what breaks
  # shutdown is ignoring TERM, or `exec ... &`, which cannot both replace the
  # shell and run in the background.
  swallowed = source.match?(/trap\s+(''|""|true|:)\s+[^\n]*\bTERM\b/)
  contradictory = source.match?(/^\s*exec\s+[^\n]*&\s*$/)
  checks["contract"] = !swallowed && !contradictory ?
    { "status" => "pass" } : { "status" => "fail", "evidence" => "termination signal swallowed or unexpected process model detected" }

when "zero-downtime-release"
  order = [
    source.index("Expand schema"),
    source.index("Deploy code"),
    source.index("Verify readiness"),
    source.index("Backfill"),
    source.index("Contract")
  ]
  valid = order.all? && order.each_cons(2).all? { |a, b| a < b }
  checks["functional"] = valid ?
    { "status" => "pass", "evidence" => "expand/deploy/readiness/backfill/contract ordering detected" } :
    { "status" => "fail", "evidence" => "release ordering is incompatible" }
  checks["contract"] = source.include?("queued-job compatibility") ?
    { "status" => "pass" } :
    { "status" => "fail", "evidence" => "queued-job compatibility missing" }

when "config-contract"
  master = source.include?("RAILS_MASTER_KEY")
  database = source.include?("DATABASE_URL")
  secret_output = source.match?(/puts\s+ENV\[|p\s+ENV\[/)
  checks["functional"] = master && database ?
    { "status" => "pass", "evidence" => "required runtime configuration keys detected" } :
    { "status" => "fail", "evidence" => "required runtime configuration missing" }
  checks["contract"] = !secret_output ?
    { "status" => "pass", "evidence" => "secret values are not printed" } :
    { "status" => "fail", "evidence" => "secret value logging detected" }

when "migration-gate"
  readiness = source.include?("Verify readiness")
  rollback = source.include?("application rollback restores database")
  destructive = source.include?("destructive")
  checks["functional"] = readiness && rollback && destructive ?
    { "status" => "pass", "evidence" => "migration readiness and rollback limitation documented" } :
    { "status" => "fail", "evidence" => "migration release gate incomplete" }
  checks["contract"] = source.include?("old processes are gone") ?
    { "status" => "pass" } :
    { "status" => "fail", "evidence" => "contract timing not explicit" }
end

test_files = Dir.glob(File.join(workspace, "{test,spec}/**/*.rb"))
if test_files.empty?
  checks["tests"] = { "status" => "fail", "evidence" => "no test/spec files found" }
else
  results = test_files.map do |file|
    out, err, status = Open3.capture3("ruby", file, chdir: workspace)
    { "file" => file, "status" => status.success? ? "pass" : "fail", "stdout" => out, "stderr" => err }
  end
  checks["tests"] = results.all? { |r| r["status"] == "pass" } ?
    { "status" => "pass", "evidence" => results } :
    { "status" => "fail", "evidence" => results }
end

changed_files = %x{git status --short}.lines.map { |line| (line[3..] || line).strip }.reject(&:empty?)
checks["scope_control"] = { "status" => "pass", "evidence" => "recorded #{changed_files.length} changed paths" }
checks.select! { |name, _| Array(evaluation.fetch("checks")).include?(name) }

result = {
  "metadata" => {
    "verifier" => "scripts/verify_production_runtime_eval.rb",
    "evaluation" => evaluation.fetch("id"),
    "implementation_file" => implementation,
    "changed_files" => changed_files
  },
  "checks" => checks
}
File.write(ENV.fetch("RUBY_AGENT_EVAL_RESULT_FILE"), JSON.pretty_generate(result) + "\n", encoding: "UTF-8")
abort "verification failed" if checks.values.any? { |value| value.fetch("status") == "fail" }
puts JSON.pretty_generate(result)
