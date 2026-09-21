#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
manifest = YAML.safe_load(
  File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)

skills = manifest.fetch("skills").keys.to_set
patterns = manifest.fetch("patterns").values.flat_map { |entry| entry.fetch("paths") }.map do |path|
  path.delete_prefix("patterns/").delete_suffix(".md")
end.to_set
pattern_names = patterns.map { |path| File.basename(path) }.to_set
errors = []

runner = manifest.fetch("runner", {})
%w[command result_schema documentation].each do |key|
  errors << "manifest runner missing #{key}" if runner[key].to_s.empty?
end

benchmark_manifest = manifest.fetch("benchmarks", {})
benchmark_manifest.each do |name, entry|
  %w[fixture_registry fixture_root verifier campaign_documentation comparison_schema].each do |key|
    errors << "benchmark #{name} missing #{key}" if entry[key].to_s.empty?
  end

  registry_path = File.join(ROOT, entry["fixture_registry"].to_s)
  fixtures_root = File.join(ROOT, entry["fixture_root"].to_s)
  verifier_path = File.join(ROOT, entry["verifier"].to_s)

  errors << "benchmark #{name} fixture registry missing #{entry["fixture_registry"]}" unless File.file?(registry_path)
  errors << "benchmark #{name} fixture root missing #{entry["fixture_root"]}" unless Dir.exist?(fixtures_root)
  errors << "benchmark #{name} verifier missing #{entry["verifier"]}" unless File.file?(verifier_path)
  errors << "benchmark #{name} campaign documentation missing #{entry["campaign_documentation"]}" unless File.file?(File.join(ROOT, entry["campaign_documentation"].to_s))
  errors << "benchmark #{name} comparison schema missing #{entry["comparison_schema"]}" unless File.file?(File.join(ROOT, entry["comparison_schema"].to_s))

  next unless File.file?(registry_path)

  begin
    registry = YAML.safe_load(
      File.read(registry_path, encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
    fixture_ids = registry.fetch("fixtures", {}).keys.to_set
    benchmark_eval_ids = Dir[File.join(ROOT, "evals", name, "*.yml")].map do |path|
      YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false).fetch("id")
    end.to_set
    missing = benchmark_eval_ids - fixture_ids
    extra = fixture_ids - benchmark_eval_ids
    errors << "benchmark #{name} missing fixtures: #{missing.to_a.sort.join(", ")}" unless missing.empty?
    errors << "benchmark #{name} has unregistered fixtures: #{extra.to_a.sort.join(", ")}" unless extra.empty?
  rescue Psych::Exception, KeyError => e
    errors << "benchmark #{name} fixture registry invalid: #{e.message}"
  end
end

evaluation_manifest = manifest.fetch("evaluations", {})
manifest_eval_paths = evaluation_manifest.values.flat_map { |entry| entry.fetch("paths", []) }.to_set

eval_files = Dir[File.join(ROOT, "evals", "**", "*.yml")].sort
abort "no evaluation files found" if eval_files.empty?

required = %w[id version title category source skills patterns prompt constraints checks cases grading]
ids = Set.new

eval_files.each do |path|
  relative = path.delete_prefix(ROOT + "/")
  begin
    data = YAML.safe_load(
      File.read(path, encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
  rescue Psych::Exception => e
    errors << "#{relative}: invalid YAML: #{e.message}"
    next
  end

  unless data.is_a?(Hash)
    errors << "#{relative}: top-level value must be a mapping"
    next
  end

  required.each do |key|
    value = data[key]
    errors << "#{relative}: missing #{key}" unless data.key?(key)
  end

  id = data["id"].to_s
  if id.empty?
    errors << "#{relative}: id must not be empty"
  elsif !ids.add?(id)
    errors << "#{relative}: duplicate evaluation id #{id}"
  end

  unless id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    errors << "#{relative}: id must be kebab-case"
  end

  Array(data["skills"]).each do |skill|
    errors << "#{relative}: unknown skill #{skill}" unless skills.include?(skill)
  end

  Array(data["patterns"]).each do |pattern|
    normalized = pattern.to_s.sub(%r{\Apattern:}, "")
    errors << "#{relative}: unknown pattern #{normalized}" unless patterns.include?(normalized) || pattern_names.include?(normalized)
  end

  %w[title source prompt].each do |field|
    errors << "#{relative}: #{field} must not be empty" if data[field].to_s.strip.empty?
  end

  cases = data["cases"]
  if !cases.is_a?(Array) || cases.empty?
    errors << "#{relative}: cases must be a non-empty array"
  else
    cases.each_with_index do |test_case, index|
      unless test_case.is_a?(Hash)
        errors << "#{relative}: case #{index} must be a mapping"
        next
      end
      %w[name input expected].each do |key|
        errors << "#{relative}: case #{index} missing #{key}" unless test_case.key?(key)
      end
    end
  end

  checks = Array(data["checks"]).map(&:to_s)
  %w[functional oop tests].each do |check|
    errors << "#{relative}: missing required check #{check}" unless checks.include?(check)
  end

  constraints = data["constraints"]
  errors << "#{relative}: constraints must be a mapping" unless constraints.is_a?(Hash)
  errors << "#{relative}: grading must be a mapping" unless data["grading"].is_a?(Hash)
end

eval_files.each do |path|
  relative = path.delete_prefix(ROOT + "/")
  unless manifest_eval_paths.include?(relative)
    errors << "#{relative}: missing from manifest evaluations section"
  end
end

evaluation_manifest.each do |name, entry|
  Array(entry.fetch("paths", [])).each do |relative|
    full_path = File.join(ROOT, relative)
    errors << "manifest evaluation #{name} points to missing file #{relative}" unless File.file?(full_path)
  end
end

if errors.any?
  warn errors.map { |error| "ERROR: #{error}" }
  abort "#{errors.length} evaluation validation error(s)"
end

puts "Validated #{eval_files.length} evaluation cases."
puts "Evaluation contract: schema + known skills/patterns + deterministic cases + independent checks"
