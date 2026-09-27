#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require "yaml"

ROOT = File.expand_path("..", __dir__)
SKILL_ROOT = File.join(ROOT, "skills")
PATTERN_ROOT = File.join(ROOT, "patterns")
EVAL_ROOT = File.join(ROOT, "evals")
BENCHMARK_ROOT = File.join(ROOT, "benchmarks")
MANIFEST_PATH = File.join(ROOT, "skill-manifest.yml")
ROUTING_PATH = File.join(ROOT, "router", "ROUTING.md")

errors = []
warnings = []

yaml = lambda do |path|
  YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
end

fenced_code_blocks = lambda { |text| text.scan(/^\s*```[A-Za-z0-9_+#.-]*\s*$/).length }
implementation_anchor = lambda do |text|
  text.match?(/\b(class|module|def|function|interface|type|const|SELECT|INSERT|UPDATE|rails runner|bin\/rails|bundle exec|npm run|yarn|pnpm)\b/i)
end

skill_files = Dir[File.join(SKILL_ROOT, "*", "SKILL.md")].sort
pattern_files = Dir[File.join(PATTERN_ROOT, "**", "*.md")].reject { |p| p.end_with?("/README.md") }.sort
eval_files = Dir[File.join(EVAL_ROOT, "**", "*.yml")].sort
campaign_files = Dir[File.join(BENCHMARK_ROOT, "*", "campaign.yml")].sort

skill_example_count = 0
skill_executable_count = 0
skill_language_counts = Hash.new(0)

skill_files.each do |path|
  text = File.read(path, encoding: "UTF-8")
  blocks = text.scan(/^\s*```([^\n]*)\n/).flatten
  skill_example_count += 1 unless blocks.empty?
  executable = blocks.any? { |lang| !lang.strip.empty? && lang.strip.downcase != "text" }
  skill_executable_count += 1 if executable
  blocks.each do |lang|
    label = lang.strip.downcase
    label = "unspecified" if label.empty?
    skill_language_counts[label] += 1
  end
end

pattern_example_count = 0
pattern_anchor_count = 0
pattern_failure_count = 0
pattern_testing_count = 0

pattern_files.each do |path|
  text = File.read(path, encoding: "UTF-8")
  pattern_example_count += 1 if text.match?(/^\s*(```|~~~)/m)
  pattern_anchor_count += 1 if implementation_anchor.call(text)
  pattern_failure_count += 1 if text.match?(/## Failure modes\b/i)
  pattern_testing_count += 1 if text.match?(/## Testing\b/i)
end

eval_nonempty_cases = 0
eval_diagnostic = 0
eval_binary_only = 0
eval_ids = {}
eval_files.each do |path|
  data = yaml.call(path)
  id = data.fetch("id").to_s
  errors << "#{path.delete_prefix(ROOT + "/")}: duplicate evaluation id #{id}" if eval_ids.key?(id)
  eval_ids[id] = path

  cases = Array(data["cases"])
  eval_nonempty_cases += 1 unless cases.empty?
  errors << "#{path.delete_prefix(ROOT + "/")}: cases must not be empty" if cases.empty?

  cases.each_with_index do |item, index|
    errors << "#{path.delete_prefix(ROOT + "/")}: case #{index} must be a mapping" unless item.is_a?(Hash)
    if item.is_a?(Hash)
      errors << "#{path.delete_prefix(ROOT + "/")}: case #{index} missing name" if item["name"].to_s.empty?
      errors << "#{path.delete_prefix(ROOT + "/")}: case #{index} missing input" unless item.key?("input")
      errors << "#{path.delete_prefix(ROOT + "/")}: case #{index} missing expected" unless item.key?("expected")
    end
  end

  grading = data["grading"].is_a?(Hash) ? data["grading"] : {}
  eval_diagnostic += 1 if grading.keys.length >= 3
  eval_binary_only += 1 if grading.keys.length <= 1
end

benchmark_ids = Set.new
campaign_files.each do |path|
  data = yaml.call(path)
  Array(data["evaluations"]).each { |id| benchmark_ids.add(id.to_s) }
end

unbenchmarked = []
static_only = []
eval_files.each do |path|
  data = yaml.call(path)
  next if benchmark_ids.include?(data.fetch("id").to_s)

  coverage = data["coverage"].to_s
  if coverage == "static-only"
    static_only << path
  else
    unbenchmarked << path
  end
end

unbenchmarked_cases = unbenchmarked.sum { |path| Array(yaml.call(path)["cases"]).length }
static_only_cases = static_only.sum { |path| Array(yaml.call(path)["cases"]).length }

routing = File.read(ROUTING_PATH, encoding: "UTF-8")
manifest = yaml.call(MANIFEST_PATH)
skill_names = manifest.fetch("skills").keys

missing_routes = skill_names.reject { |name| routing.include?(name) }
errors << "skills missing from router: #{missing_routes.join(", ")}" unless missing_routes.empty?

trigger_owners = Hash.new { |h, k| h[k] = [] }
skill_names.each do |name|
  Array(manifest.fetch("skills").fetch(name)["triggers"]).each do |trigger|
    normalized = trigger.to_s.strip.downcase
    trigger_owners[normalized] << name unless normalized.empty?
  end
end
trigger_collisions = trigger_owners.count { |_trigger, owners| owners.uniq.length > 1 }

stale_manifest_paths = manifest.fetch("skills").sum do |name, entry|
  File.file?(File.join(ROOT, entry.fetch("path"))) ? 0 : 1
end

puts "Corpus quality audit"
puts "  Skills: #{skill_files.length}"
puts "  skills: #{skill_example_count}/#{skill_files.length} with reference examples (fenced code blocks)"
puts "  skills: #{skill_executable_count}/#{skill_files.length} with executable examples (named code fences)"
puts "  skill example languages: #{skill_language_counts.sort.map { |k, v| "#{k}=#{v}" }.join(", ")}"
puts "  Patterns: #{pattern_files.length}"
puts "  patterns: #{pattern_example_count}/#{pattern_files.length} with Structure/example code"
puts "  patterns: #{pattern_anchor_count}/#{pattern_files.length} with implementation anchors"
puts "  patterns: #{pattern_failure_count}/#{pattern_files.length} with failure-mode guidance"
puts "  patterns: #{pattern_testing_count}/#{pattern_files.length} with testing guidance"
puts "  Evaluations: #{eval_files.length}"
puts "  evaluations: #{eval_nonempty_cases}/#{eval_files.length} with non-empty cases"
puts "  evaluations: #{eval_diagnostic}/#{eval_files.length} with >=3 grading dimensions"
puts "  evaluations: #{eval_binary_only}/#{eval_files.length} binary-only grading"
puts "  Benchmark coverage: #{benchmark_ids.length}/#{eval_files.length} evaluation IDs covered by campaigns"
puts "  unbenchmarked: #{unbenchmarked.length} files (#{unbenchmarked_cases} cases)"
puts "  static-only: #{static_only.length} files (#{static_only_cases} cases)"
puts "  Routing: #{skill_names.length - missing_routes.length}/#{skill_names.length} skills routed"
puts "  routing trigger collisions: #{trigger_collisions}"
puts "  stale manifest skill paths: #{stale_manifest_paths}"

warnings << "public evaluations without a benchmark campaign: #{unbenchmarked.length} files (#{unbenchmarked_cases} cases)" unless unbenchmarked.empty?
errors << "skills with no code/reference example: #{skill_files.length - skill_example_count}" if skill_example_count < skill_files.length
errors << "patterns with no code example: #{pattern_files.length - pattern_example_count}" if pattern_example_count < pattern_files.length
warnings << "patterns with no implementation anchor: #{pattern_files.length - pattern_anchor_count}" if pattern_anchor_count < pattern_files.length

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} corpus quality error(s)"
end

warnings.each { |warning| puts "WARN: #{warning}" }
puts "Corpus quality audit passed."
