#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "shellwords"

ROOT = File.expand_path("..", __dir__)
errors = []
warnings = []

required_files = %w[
  README.md AGENTS.md LICENSE CONTRIBUTING.md SECURITY.md CHANGELOG.md
  skill-manifest.yml router/ROUTING.md bin/validate bin/eval bin/benchmark
  docs/SOURCE_COVERAGE.md docs/SKILL_CONTRACT.md docs/PATTERN_SCHEMA.md docs/EVAL_SCHEMA.md
  docs/BENCHMARK_QUALITY_AUDIT.md docs/REPOSITORY_COMPLETENESS_AUDIT.md docs/RELEASE_READINESS_AUDIT.md
]

required_files.each do |path|
  errors << "missing release file #{path}" unless File.file?(File.join(ROOT, path))
end

readme = File.read(File.join(ROOT, "README.md"), encoding: "UTF-8")
manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"), permitted_classes: [], aliases: false)

current_milestone = readme[/Current milestone:\*\* Iteration (\d+)/, 1].to_i
errors << "README is not at a post-release milestone" unless current_milestone >= 51
errors << "README has no final release section" unless readme.include?("Final Release and Public-Readiness Hardening")
errors << "README still claims Iteration 47 is current" if readme.include?("Current milestone:** Iteration 47")
errors << "README contains stale evaluation count 206" if readme.include?("206 evaluation cases")
errors << "README contains stale evaluation count 193" if readme.include?("193 evaluation cases")
errors << "README contains stale pattern count 394" if readme.include?("394 implementation patterns")
errors << "README inventory is missing skills" unless readme.match?(/\| Skills \| \*\*\d+\*\* \|/)
errors << "README inventory is missing implementation patterns" unless readme.match?(/\| Implementation patterns \| \*\*\d+\*\* \|/)
errors << "README inventory is missing evaluation cases" unless readme.match?(/\| Evaluation cases \| \*\*\d+\*\* \|/)

tracked_generated = `git -C #{Shellwords.escape(ROOT)} ls-files benchmark-results 2>/dev/null`.lines
errors << "generated benchmark-results are tracked" unless tracked_generated.empty?

manifest_name = manifest["name"].to_s
errors << "manifest name missing" if manifest_name.empty?
errors << "manifest version must be >= 2" unless manifest["version"].to_i >= 2

text_files = Dir[File.join(ROOT, "*.md")] + Dir[File.join(ROOT, "docs", "*.md")] + Dir[File.join(ROOT, "router", "*.md")]
joined = text_files.filter_map { |path| File.read(path, encoding: "UTF-8") rescue nil }.join("\n")
[
  "Current milestone:** Iteration 47",
  "Current validated evaluation inventory: **206",
  "Current validated evaluation inventory: **80",
  "339 implementation patterns",
  "139 evaluation cases"
].each do |marker|
  errors << "stale release marker #{marker.inspect}" if joined.include?(marker)
end

puts "Release readiness audit"
puts "  required release files: #{required_files.length}"
puts "  skills: #{manifest.fetch("skills").length}"
puts "  generated benchmark-results tracked: #{tracked_generated.length}"
warnings.each { |warning| puts "WARN: #{warning}" }

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} release readiness error(s)"
end

puts "Release readiness audit passed."
