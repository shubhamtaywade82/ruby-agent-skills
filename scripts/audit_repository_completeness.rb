#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require "yaml"

ROOT = File.expand_path("..", __dir__)
MANIFEST_PATH = File.join(ROOT, "skill-manifest.yml")
README_PATH = File.join(ROOT, "README.md")
ROUTING_PATH = File.join(ROOT, "router", "ROUTING.md")
VALIDATE_PATH = File.join(ROOT, "bin", "validate")

abort "missing skill-manifest.yml" unless File.file?(MANIFEST_PATH)

manifest = YAML.safe_load(
  File.read(MANIFEST_PATH, encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)

errors = []
warnings = []

installation = manifest.fetch("installation", {})
installation_paths = {
  "installer" => installation.fetch("installer"),
  "verifier" => installation.fetch("verifier"),
  "doctor" => installation.fetch("doctor")
}
installation_paths.each do |kind, path|
  errors << "manifest installation #{kind} missing file #{path}" unless File.file?(File.join(ROOT, path))
end

skill_files = Dir[File.join(ROOT, "skills", "*", "SKILL.md")].map { |p| p.delete_prefix(ROOT + "/") }.sort
manifest_skills = manifest.fetch("skills")
manifest_skill_paths = manifest_skills.values.map { |entry| entry.fetch("path") }.sort

errors << "skill file/manifest mismatch" unless skill_files == manifest_skill_paths

manifest_skills.each do |name, entry|
  path = entry.fetch("path")
  errors << "manifest skill #{name} missing file #{path}" unless File.file?(File.join(ROOT, path))
  errors << "skill #{name} has no triggers" if Array(entry["triggers"]).empty?
end

pattern_files = Dir[File.join(ROOT, "patterns", "**", "*.md")]
  .reject { |p| p.end_with?("/README.md") }
  .map { |p| p.delete_prefix(ROOT + "/") }
  .sort

pattern_refs = manifest.fetch("patterns").each_with_object([]) do |(_category, entry), refs|
  refs.concat(Array(entry.fetch("paths")))
end

missing_pattern_refs = pattern_refs.uniq.reject { |p| File.file?(File.join(ROOT, p)) }
orphan_patterns = pattern_files.reject { |p| pattern_refs.include?(p) }
errors << "manifest references missing patterns: #{missing_pattern_refs.join(", ")}" unless missing_pattern_refs.empty?
errors << "unregistered pattern files: #{orphan_patterns.join(", ")}" unless orphan_patterns.empty?

duplicate_patterns = pattern_refs.tally.select { |_path, count| count > 1 }
unexpected_duplicates = duplicate_patterns.keys.reject do |path|
  manifest.fetch("patterns").fetch("testing").fetch("paths").include?(path)
end
errors << "unexpected duplicate pattern registrations: #{unexpected_duplicates.join(", ")}" unless unexpected_duplicates.empty?
warnings << "testing registry intentionally dual-registers #{duplicate_patterns.size} patterns" unless duplicate_patterns.empty?

eval_files = Dir[File.join(ROOT, "evals", "**", "*.yml")].map { |p| p.delete_prefix(ROOT + "/") }.sort
eval_refs = manifest.fetch("evaluations").values.flat_map { |entry| Array(entry.fetch("paths")) }.sort
errors << "evaluation file/manifest mismatch" unless eval_files == eval_refs

eval_refs.each do |path|
  errors << "manifest references missing evaluation #{path}" unless File.file?(File.join(ROOT, path))
end

skill_names = manifest_skills.keys
routing = File.read(ROUTING_PATH, encoding: "UTF-8")
missing_routes = skill_names.reject { |name| routing.include?(name) }
errors << "skills missing from router: #{missing_routes.join(", ")}" unless missing_routes.empty?

validate = File.read(VALIDATE_PATH, encoding: "UTF-8")
system_tests = Dir[File.join(ROOT, "test", "*_system_test.rb")]
  .map { |p| p.delete_prefix(ROOT + "/") }
  .sort
invoked_system_tests = validate.scan(%r{test/[^\s"']+_system_test\.rb}).uniq.sort
missing_system_tests = system_tests.reject { |path| invoked_system_tests.include?(path) }
stale_system_tests = invoked_system_tests.reject { |path| File.file?(File.join(ROOT, path)) }
errors << "system tests not invoked by bin/validate: #{missing_system_tests.join(", ")}" unless missing_system_tests.empty?
errors << "bin/validate invokes missing system tests: #{stale_system_tests.join(", ")}" unless stale_system_tests.empty?

stack_minimality_files = eval_files.select { |path| path.start_with?("evals/stack-minimality/") }
expected_stack_minimality_evals = Dir[File.join(ROOT, "evals", "stack-minimality", "*.yml")].
  map { |p| p.delete_prefix(ROOT + "/") }.
  sort
errors << "stack-minimality evaluation registry mismatch" unless stack_minimality_files == expected_stack_minimality_evals
errors << "stack-minimality evaluation count must be >= 13" unless stack_minimality_files.length >= 13

eval_case_count = eval_files.sum do |relative|
  data = YAML.safe_load(
    File.read(File.join(ROOT, relative), encoding: "UTF-8"),
    permitted_classes: [],
    aliases: false
  )
  Array(data.fetch("cases")).length
end

readme = File.read(README_PATH, encoding: "UTF-8")
inventory = {
  "Skills" => skill_files.length,
  "Implementation patterns" => pattern_files.length,
  "Evaluation cases" => eval_case_count,
  "Dedicated system/contract tests" => system_tests.length
}

inventory.each do |label, expected|
  pattern = /\| #{Regexp.escape(label)} \| \*\*(\d+)\*\* \|/
  actual = readme[pattern, 1]&.to_i
  errors << "README #{label} count #{actual.inspect} != #{expected}" unless actual == expected
end

current_milestone = readme[/Current milestone:\*\* Iteration (\d+)/, 1].to_i
errors << "README current milestone is not an active post-audit milestone" unless current_milestone >= 51
errors << "README still contains the stale pre-Iteration-46 roadmap text" if readme.include?("The next planned deep Rails boundary is **Authorization Engineering**")

puts "Repository completeness audit"
puts "  skills: #{skill_files.length}"
puts "  implementation patterns: #{pattern_files.length}"
puts "  evaluation files: #{eval_files.length}"
puts "  evaluation cases: #{eval_case_count}"
puts "  system tests: #{system_tests.length}"
puts "  routed skills: #{skill_names.length - missing_routes.length}/#{skill_names.length}"
puts "  invoked system tests: #{invoked_system_tests.length}/#{system_tests.length}"
warnings.each { |warning| puts "WARN: #{warning}" }

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} completeness audit error(s)"
end

puts "Completeness audit passed."
