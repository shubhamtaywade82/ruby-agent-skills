#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
MANIFEST_PATH = File.join(ROOT, "skill-manifest.yml")
MIGRATION_DOC = "docs/REACT_AGENT_SKILLS_MIGRATION.md"
REQUIRED_SCOPE = "new_standalone_react_typescript_work"

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
  errors << "deprecation #{skill} references an unregistered skill" unless skills.key?(skill)

  unless entry.is_a?(Hash)
    errors << "deprecation #{skill} must be a mapping"
    next
  end

  validate_entry(errors, skill, entry)
end

replacements = entries.values.filter_map do |entry|
  entry["replacement"] if entry.is_a?(Hash)
end
duplicates = replacements.tally.select { |_replacement, count| count > 1 }
duplicates.each_key do |replacement|
  errors << "replacement #{replacement} is declared more than once"
end

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} deprecation governance error(s)"
end

puts "Validated #{entries.length} deprecation entries."

def validate_entry(errors, skill, entry)
  errors << "deprecation #{skill} must have status deprecated" unless entry["status"] == "deprecated"
  unless entry["scope"] == REQUIRED_SCOPE
    errors << "deprecation #{skill} has an invalid scope"
  end

  replacement = entry["replacement"]
  unless replacement.is_a?(String) && replacement.match?(/\Areact-agent-skills \/ .+/)
    errors << "deprecation #{skill} must declare a react-agent-skills replacement"
  end

  migration_doc = entry["migration_doc"]
  unless migration_doc == MIGRATION_DOC &&
         File.file?(File.join(ROOT, migration_doc.to_s))
    errors << "deprecation #{skill} must point to the migration document"
  end

  gate = entry["removal_gate"]
  valid_gate = gate.is_a?(Array) &&
               gate.length == 5 &&
               gate.all? { |item| item.is_a?(String) && !item.strip.empty? }
  errors << "deprecation #{skill} must declare exactly five non-empty removal gates" unless valid_gate
end
