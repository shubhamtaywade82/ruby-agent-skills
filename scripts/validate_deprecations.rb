# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
MANIFEST_PATH = File.join(ROOT, "skill-manifest.yml")
MIGRATION_DOC = "docs/REACT_AGENT_SKILLS_MIGRATION.md"
REQUIRED_SCOPE = "new_standalone_react_typescript_work"

def validate_status_and_scope(errors, skill, entry)
  unless entry["status"] == "deprecated"
    errors << "deprecation #{skill} must have status deprecated"
  end
  return if entry["scope"] == REQUIRED_SCOPE

  errors << "deprecation #{skill} has an invalid scope"
end

def validate_replacement(errors, skill, entry)
  replacement = entry["replacement"]
  return if replacement.is_a?(String) && replacement.match?(%r{\Areact-agent-skills / .+})

  errors << "deprecation #{skill} must declare a react-agent-skills replacement"
end

def validate_migration_doc(errors, skill, entry)
  migration_doc = entry["migration_doc"]
  valid = migration_doc == MIGRATION_DOC &&
          File.file?(File.join(ROOT, migration_doc.to_s))
  return if valid

  errors << "deprecation #{skill} must point to the migration document"
end

def validate_removal_gate(errors, skill, entry)
  gate = entry["removal_gate"]
  valid = gate.is_a?(Array) &&
          gate.length == 5 &&
          gate.all? { |item| item.is_a?(String) && !item.strip.empty? }
  return if valid

  errors << "deprecation #{skill} must declare exactly five non-empty removal gates"
end

# Agents select skills from SKILL.md frontmatter descriptions, not from the
# manifest, so a deprecation is only effective when the description says so.
def validate_frontmatter_notice(errors, skill, entry)
  path = File.join(ROOT, "skills", skill, "SKILL.md")
  return errors << "deprecation #{skill} has no SKILL.md" unless File.file?(path)

  frontmatter = File.read(path, encoding: "UTF-8")[/\A---\n(.*?)\n---\n/m, 1].to_s
  description = YAML.safe_load(frontmatter, permitted_classes: [], aliases: false)&.fetch(
    "description", nil
  ).to_s
  return if description.start_with?("DEPRECATED") && description.include?(entry["replacement"].to_s)

  errors << "deprecation #{skill} description must start with DEPRECATED and name its replacement"
end

def validate_entry(errors, skill, entry)
  validate_status_and_scope(errors, skill, entry)
  validate_replacement(errors, skill, entry)
  validate_migration_doc(errors, skill, entry)
  validate_removal_gate(errors, skill, entry)
  validate_frontmatter_notice(errors, skill, entry)
end

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
