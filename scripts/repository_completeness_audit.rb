#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require "yaml"

ROOT = File.expand_path("..", __dir__)
MANIFEST_PATH = File.join(ROOT, "skill-manifest.yml")
README_PATH = File.join(ROOT, "README.md")
VALIDATE_PATH = File.join(ROOT, "bin", "validate")

abort "missing skill-manifest.yml" unless File.file?(MANIFEST_PATH)

manifest = YAML.safe_load(
  File.read(MANIFEST_PATH, encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)

errors = []

skills_manifest = manifest.fetch("skills")
patterns_manifest = manifest.fetch("patterns").values.flat_map { |entry| entry.fetch("paths") }
evaluations_manifest = manifest.fetch("evaluations").values.flat_map { |entry| entry.fetch("paths") }

skill_files = Dir[File.join(ROOT, "skills", "*", "SKILL.md")].sort.map { |p| p.delete_prefix(ROOT + "/") }
pattern_files = Dir[File.join(ROOT, "patterns", "**", "*.md")].reject { |p| p.end_with?("/README.md") }.sort.map { |p| p.delete_prefix(ROOT + "/") }
evaluation_files = Dir[File.join(ROOT, "evals", "**", "*.yml")].sort.map { |p| p.delete_prefix(ROOT + "/") }
system_test_files = Dir[File.join(ROOT, "test", "*_system_test.rb")].sort.map { |p| p.delete_prefix(ROOT + "/") }
validate_text = File.read(VALIDATE_PATH, encoding: "UTF-8")

skill_paths = skills_manifest.values.map { |entry| entry.fetch("path") }
errors << "skill registry contains duplicate paths" unless skill_paths.uniq.length == skill_paths.length
errors << "skill file/registry mismatch" unless skill_files.sort == skill_paths.sort

patterns_manifest_paths = patterns_manifest
errors << "manifest references missing pattern files" unless (patterns_manifest_paths - pattern_files).empty?
errors << "pattern files missing from manifest" unless (pattern_files - patterns_manifest_paths).empty?

evaluations_manifest_paths = evaluations_manifest
errors << "manifest references missing evaluation files" unless (evaluations_manifest_paths - evaluation_files).empty?
errors << "evaluation files missing from manifest" unless (evaluation_files - evaluations_manifest_paths).empty?

router_text = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")
skills_manifest.each_key do |skill_name|
  errors << "skill #{skill_name} missing from router" unless router_text.include?(skill_name)
end

system_test_files.each do |relative|
  errors << "system test #{relative} is not invoked by bin/validate" unless validate_text.include?(relative)
end
invoked_system_tests = validate_text.scan(%r{test/([A-Za-z0-9_]+_system_test\.rb)}).map { |name| "test/#{name}" }.uniq
errors << "bin/validate invokes missing system tests: #{(invoked_system_tests - system_test_files).sort.join(", ")}" unless (invoked_system_tests - system_test_files).empty?

readme = File.read(README_PATH, encoding: "UTF-8")
skill_count = skill_files.length
pattern_count = pattern_files.length
eval_case_count = evaluation_files.sum do |path|
  data = YAML.safe_load(File.read(File.join(ROOT, path), encoding: "UTF-8"), permitted_classes: [], aliases: false)
  Array(data.fetch("cases")).length
end

errors << "README skill inventory drift" unless readme.match?(/\| Skills \| \*\*#{skill_count}\*\* \|/)
errors << "README pattern inventory drift" unless readme.match?(/\| Implementation patterns \| \*\*#{pattern_count}\*\* \|/)
errors << "README evaluation-case inventory drift" unless readme.match?(/\| Evaluation cases \| \*\*#{eval_case_count}\*\* \|/)

if errors.any?
  warn errors.map { |error| "ERROR: #{error}" }
  abort "#{errors.length} completeness audit error(s)"
end

puts "Completeness audit passed."
puts "Skills: #{skill_count}"
puts "Implementation patterns: #{pattern_count}"
puts "Evaluation cases: #{eval_case_count}"
puts "System tests: #{system_test_files.length}"
