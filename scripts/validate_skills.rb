#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
manifest_path = File.join(ROOT, "skill-manifest.yml")

abort "missing skill-manifest.yml" unless File.file?(manifest_path)

manifest = YAML.load_file(manifest_path)
skills_manifest = manifest.fetch("skills")

skill_files = Dir[File.join(ROOT, "skills", "*", "SKILL.md")].sort
abort "no SKILL.md files found" if skill_files.empty?

names = Set.new
errors = []

skill_files.each do |path|
  relative = path.delete_prefix(ROOT + "/")
  folder = File.basename(File.dirname(path))
  text = File.read(path, encoding: "UTF-8")

  unless text.start_with?("---\n")
    errors << relative + ": missing YAML frontmatter"
    next
  end

  closing = text.index("\n---\n", 4)

  unless closing
    errors << relative + ": unterminated YAML frontmatter"
    next
  end

  frontmatter_text = text[4...closing]

  begin
    metadata = YAML.safe_load(frontmatter_text, permitted_classes: [], aliases: false)
  rescue Psych::Exception => e
    errors << relative + ": invalid frontmatter: " + e.message
    next
  end

  unless metadata.is_a?(Hash)
    errors << relative + ": frontmatter must be a mapping"
    next
  end

  name = metadata["name"]
  description = metadata["description"]

  errors << relative + ": missing name" if name.to_s.empty?
  errors << relative + ": missing description" if description.to_s.empty?
  errors << relative + ": name must match directory " + folder unless name == folder

  if name && !name.to_s.empty?
    errors << relative + ": duplicate skill name " + name unless names.add?(name)
    errors << relative + ": missing from skill-manifest.yml" unless skills_manifest.key?(name)
  end

  body = text[(closing + 5)..] || ""

  required_sections = {
    "Purpose" => /## Purpose\b/,
    "Activate when" => /## Activate when\b/,
    "Repository inspection" => /## Repository inspection\b/,
    "Agent review checklist" => /## Agent review checklist\b/,
    "Verification" => /## Verification\b/,
    "Source foundation" => /## Source foundation\b/
  }

  required_sections.each do |label, pattern|
    errors << relative + ": missing #{label} section" unless body.match?(pattern)
  end

  procedural = /(decision rules|procedure|process|change|refactor|debug|test|review|verification|release|initialization|loading|parsing|migration|generation|loop|workflow)/i
  failure_modes = /(anti-pattern|failure|risk|security|avoid|never|do not|pitfall|common trap|common mistake)/i

  errors << relative + ": missing implementation/decision guidance" unless body.match?(procedural)
  errors << relative + ": missing failure/risk/avoidance guidance" unless body.match?(failure_modes)
end

skill_files.each do |path|
  folder = File.basename(File.dirname(path))
  entry = skills_manifest[folder]
  next unless entry

  expected = path.delete_prefix(ROOT + "/")
  actual = entry["path"]

  errors << "manifest path mismatch for " + folder + ": " + actual.to_s + " != " + expected unless actual == expected
end

skills_manifest.each do |name, entry|
  path = entry["path"]
  full_path = File.join(ROOT, path)

  errors << "manifest skill " + name + " points to missing file " + path unless File.file?(full_path)
end

unless manifest["defaults"].is_a?(Hash)
  errors << "manifest missing defaults mapping"
end

if errors.any?
  warn errors.map { |error| "ERROR: " + error }
  abort errors.length.to_s + " validation error(s)"
end

puts "Validated " + skill_files.length.to_s + " skills."
puts "Manifest contains " + skills_manifest.length.to_s + " skills."
puts "Skill contract: frontmatter + activation + inspection + review + verification + source + decision/failure guidance"
