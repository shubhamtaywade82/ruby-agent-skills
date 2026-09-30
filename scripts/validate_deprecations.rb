#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
MANIFEST_PATH = File.join(ROOT, "skill-manifest.yml")

abort "missing skill-manifest.yml" unless File.file?(MANIFEST_PATH)

manifest = YAML.safe_load(
  File.read(MANIFEST_PATH, encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)

skills = manifest.fetch("skills")
entries = manifest.fetch("deprecations")

errors = []
unless entries.is_a?(Hash) && entries.any?
  errors << "deprecations must be a non-empty mapping"
  entries = {}
end

entries.each do |skill, entry|
  unless skills.key?(skill)
    errors << "deprecation #{skill} references an unregistered skill"
  end

  unless entry.is_a?(Hash)
    errors << "deprecation #{skill} must be a mapping"
    next
  end

  errors << "deprecation #{skill} must have status deprecated" unless entry["status"] == "deprecated"
  errors << "deprecation #{skill} must declare scope new_standalone_react_typescript_work" unless entry["scope"] == "new_standalone_react_typescript_work"

  replacement = entry["replacement"]
  unless replacement.is_a?(String) && replacement.match?(/Areact-agent-skills \/ .+/)
    errors << "deprecation #{skill} must declare a react-agent-skills replacement"
  end

  migration_doc = entry["migration_doc"]
  unless migration_doc == "docs/REACT_AGENT_SKILLS_MIGRATION.md" &&
         File.file?(File.join(ROOT, migration_doc.to_s))
    errors << "deprecation #{skill} must point to the migration document"
  end

  gate = entry["removal_gate"]
  unless gate.is_a?(Array) && gate.length == 5 && gate.all? { |item| item.is_a?(String) && !item.strip.empty? }
    errors << "deprecation #{skill} must declare exactly five non-empty removal gates"
  end
end

duplicate_replacements = entries.values.filter_map { |entry| entry["replacement"] if entry.is_a?(Hash) }
                                   .tally
                                   .select { |_replacement, count| count > 1 }
unless duplicate_replacements.empty?
  # Multiple deprecated skills may intentionally share a destination only when
  # the replacement explicitly names the distinct destination capability.
  duplicate_replacements.each do |replacement, count|
    errors << "replacement #{replacement} is declared #{count} times; use distinct destination capabilities"
  end
end

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} deprecation governance error(s)"
end

puts "Validated #{entries.length} deprecation entries."
