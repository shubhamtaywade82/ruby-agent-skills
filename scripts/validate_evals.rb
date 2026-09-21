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

runner = manifest.fetch("runner", {})
%w[command result_schema documentation].each do |key|
  errors << "manifest runner missing #{key}" if runner[key].to_s.empty?
end

evaluation_manifest = manifest.fetch("evaluations", {})
manifest_eval_paths = evaluation_manifest.values.flat_map { |entry| entry.fetch("paths", []) }.to_set

eval_files = Dir[File.join(ROOT, "evals", "**", "*.yml")].sort
abort "no evaluation files found" if eval_files.empty?

required = %w[id version title category source skills patterns prompt constraints checks cases grading]
ids = Set.new
errors = []

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
