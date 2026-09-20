#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

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
