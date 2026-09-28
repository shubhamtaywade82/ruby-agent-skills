#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "yaml"
require "set"

# Agent Skills progressive disclosure: the whole SKILL.md loads on activation,
# so it stays within the specification's recommended budget (500 lines,
# ~5,000 tokens). Deep knowledge moves to skill-local references/ files that
# load on demand, one level deep. The target is this repository's quality bar
# and is reported, not enforced.
MAX_SKILL_LINES = 500
MAX_SKILL_TOKENS = 5_000
TARGET_SKILL_LINES = 350
TARGET_SKILL_TOKENS = 3_500
MAX_REFERENCE_LINES = 500
ALLOWED_SKILL_ENTRIES = %w[SKILL.md references scripts assets].freeze

# Deterministic estimate (about four bytes per token for English Markdown);
# never reported as a measured tokenizer count.
def estimated_tokens(text)
  (text.bytesize / 4.0).ceil
end

options = { root: File.expand_path("..", __dir__) }
OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/validate_skills.rb [--root PATH]"
  opts.on("--root PATH", "Repository root to validate") { |value| options[:root] = File.expand_path(value) }
end.parse!

ROOT = options[:root]
manifest_path = File.join(ROOT, "skill-manifest.yml")

abort "missing skill-manifest.yml" unless File.file?(manifest_path)

manifest = YAML.load_file(manifest_path)
skills_manifest = manifest.fetch("skills")

skill_files = Dir[File.join(ROOT, "skills", "*", "SKILL.md")].sort
abort "no SKILL.md files found" if skill_files.empty?

names = Set.new
errors = []
registered_patterns = manifest.fetch("patterns", {}).values
                              .flat_map { |entry| Array(entry["paths"]) }
                              .to_set { |path| File.basename(path, ".md") }
above_target = []
reference_count = 0

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

  line_count = text.lines.length
  tokens = estimated_tokens(text)
  errors << "#{relative}: #{line_count} lines exceeds the #{MAX_SKILL_LINES}-line SKILL.md limit; move deep knowledge to references/" if line_count > MAX_SKILL_LINES
  errors << "#{relative}: ~#{tokens} estimated tokens exceeds the #{MAX_SKILL_TOKENS}-token SKILL.md limit; move deep knowledge to references/" if tokens > MAX_SKILL_TOKENS
  above_target << "#{folder} (#{line_count} lines, ~#{tokens} tokens)" if line_count > TARGET_SKILL_LINES || tokens > TARGET_SKILL_TOKENS

  skill_dir = File.dirname(path)
  (Dir.children(skill_dir) - ALLOWED_SKILL_ENTRIES).sort.each do |entry|
    errors << "#{relative}: unexpected skill entry #{entry}; allowed: #{ALLOWED_SKILL_ENTRIES.join(', ')}"
  end

  references_dir = File.join(skill_dir, "references")
  reference_files = []
  if File.directory?(references_dir)
    Dir.children(references_dir).sort.each do |entry|
      entry_path = File.join(references_dir, entry)
      if File.directory?(entry_path) || !entry.end_with?(".md")
        errors << "#{relative}: references/#{entry} must be a Markdown file directly under references/ (one level deep)"
      else
        reference_files << entry
      end
    end
  end

  linked = body.scan(%r{\]\((references/[^)\s#]+)\)}).flatten.uniq
  mentioned = body.scan(%r{\breferences/[A-Za-z0-9._-]+\.md\b}).uniq
  (linked | mentioned).each do |target|
    errors << "#{relative}: reference #{target} does not exist" unless File.file?(File.join(skill_dir, target))
  end
  reference_files.each do |entry|
    errors << "#{relative}: references/#{entry} is not linked from SKILL.md" unless linked.include?("references/#{entry}")
  end

  if reference_files.any?
    references_section = body[/^## References\n(.*?)(?=^## |\z)/m, 1]
    if references_section.nil?
      errors << "#{relative}: skills with references/ must index them in a ## References section"
    else
      references_section.scan(/^\|.*\|$/).each do |row|
        cells = row.split("|").map(&:strip)
        next unless cells.any? { |cell| cell.include?("](references/") }

        cells.last.to_s.scan(/`([a-z0-9-]+)`/).flatten.each do |pattern|
          errors << "#{relative}: References names unregistered pattern #{pattern}" unless registered_patterns.include?(pattern)
        end
      end
    end
  end

  reference_files.each do |entry|
    reference_count += 1
    reference_relative = "#{File.dirname(relative)}/references/#{entry}"
    reference_text = File.read(File.join(references_dir, entry), encoding: "UTF-8")
    errors << "#{reference_relative}: must start with a level-1 heading" unless reference_text.start_with?("# ")
    if reference_text.lines.length > MAX_REFERENCE_LINES
      errors << "#{reference_relative}: #{reference_text.lines.length} lines exceeds the #{MAX_REFERENCE_LINES}-line reference limit; split by knowledge boundary"
    end
    chained = reference_text.scan(/\]\(([^)\s#]+\.md)(?:#[^)]*)?\)/).flatten.grep_v(%r{\Ahttps?://})
    chained |= reference_text.scan(%r{\breferences/[A-Za-z0-9._-]+\.md\b})
    chained.each do |target|
      errors << "#{reference_relative}: links to #{target}; reference files must stay one level deep"
    end
  end
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
puts "Size policy: SKILL.md <= #{MAX_SKILL_LINES} lines and <= ~#{MAX_SKILL_TOKENS} estimated tokens; " \
     "#{reference_count} references, one level deep, each <= #{MAX_REFERENCE_LINES} lines"
unless above_target.empty?
  puts "Above the #{TARGET_SKILL_LINES}-line / ~#{TARGET_SKILL_TOKENS}-token target (#{above_target.length}): #{above_target.join(', ')}"
end
