#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "../lib/ruby_agent_skills/version_constraint"

ROOT = File.expand_path("..", __dir__)
pattern_files = Dir[File.join(ROOT, "patterns", "**", "*.md")]
                .reject { |path| path.end_with?("/README.md") }

abort "no pattern files found" if pattern_files.empty?

errors = []

pattern_files.each do |path|
  relative = path.delete_prefix(ROOT + "/")
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

  begin
    metadata = YAML.safe_load(text[4...closing], permitted_classes: [], aliases: false)
  rescue Psych::Exception => e
    errors << relative + ": invalid frontmatter: " + e.message
    next
  end

  unless metadata.is_a?(Hash)
    errors << relative + ": frontmatter must be a mapping"
    next
  end

  errors << relative + ": missing name" if metadata["name"].to_s.empty?
  errors << relative + ": missing description" if metadata["description"].to_s.empty?
  errors << relative + ": missing family" if metadata["family"].to_s.empty?
  if metadata.key?("compatibility")
    compatibility = metadata["compatibility"]
    unless compatibility.is_a?(Hash) && compatibility.all? { |runtime, requirement| runtime.is_a?(String) && requirement.is_a?(String) && !requirement.strip.empty? }
      errors << relative + ": compatibility must be a mapping of string runtime names to string requirements"
    else
      compatibility.each do |runtime, requirement|
        begin
          RubyAgentSkills::VersionConstraint.validate(requirement)
        rescue RubyAgentSkills::VersionConstraint::InvalidRequirement => e
          errors << relative + ": invalid #{runtime} compatibility requirement: #{e.message}"
        end
      end
    end
  end

  body = text[(closing + 5)..] || ""

  [
    "Problem",
    "Use when",
    "Do not use when",
    "Repository inspection",
    "Implementation procedure",
    "Failure modes",
    "Testing",
    "Review checklist",
    "Related skills"
  ].each do |section|
    errors << relative + ": missing " + section unless body.include?("## " + section)
  end
end

if errors.any?
  warn errors.map { |error| "ERROR: " + error }
  abort errors.length.to_s + " pattern validation error(s)"
end

puts "Validated " + pattern_files.length.to_s + " implementation patterns."
