#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "yaml"

default_root = File.expand_path("..", __dir__)
options = {root: default_root}

OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/audit_documentation_consistency.rb [--root PATH]"
  opts.on("--root PATH", "Repository root to audit") { |value| options[:root] = File.expand_path(value) }
end.parse!

root = options[:root]
readme_path = File.join(root, "README.md")
changelog_path = File.join(root, "CHANGELOG.md")
handoff_path = File.join(root, "docs", "IMPLEMENTATION_HANDOFF.md")
manifest_path = File.join(root, "skill-manifest.yml")

[readme_path, changelog_path, handoff_path, manifest_path].each do |path|
  abort "missing documentation audit input: #{path}" unless File.file?(path)
end

readme = File.read(readme_path, encoding: "UTF-8")
changelog = File.read(changelog_path, encoding: "UTF-8")
handoff = File.read(handoff_path, encoding: "UTF-8")
manifest = YAML.safe_load(File.read(manifest_path, encoding: "UTF-8"), permitted_classes: [], aliases: false)

skill_count = Dir[File.join(root, "skills", "*", "SKILL.md")].length
pattern_count = Dir[File.join(root, "patterns", "**", "*.md")].reject { |path| path.end_with?("/README.md") }.length
evaluation_count = Dir[File.join(root, "evals", "**", "*.yml")].sum do |path|
  data = YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
  Array(data.fetch("cases")).length
end
system_test_count = Dir[File.join(root, "test", "*_system_test.rb")].length

latest_changelog = changelog[/^## Iteration (\d+)/, 1].to_i
readme_milestone = readme[/Current milestone:\*\* Iteration (\d+)/, 1].to_i
handoff_milestones = handoff.scan(/complete through Iteration (\d+)/).flatten.map(&:to_i).uniq

errors = []
errors << "README current milestone #{readme_milestone} != latest changelog #{latest_changelog}" unless readme_milestone == latest_changelog
errors << "IMPLEMENTATION_HANDOFF.md status #{handoff_milestones.inspect} != latest changelog #{latest_changelog}" unless handoff_milestones == [latest_changelog]

# AGENTS.md is loaded on every task, so it holds only the repository-wide
# operating contract. Domain rules live in the owning skill's
# "## <Domain> changes" section and load only when that skill is routed.
AGENTS_LINE_BUDGET = 150
REPOSITORY_CHANGE_SECTIONS = [
  "Release and public-readiness changes",
  "Evaluation and benchmark changes",
  "Repository completeness and framework drift changes"
].freeze
agents_path = File.join(root, "AGENTS.md")
if File.file?(agents_path)
  agents = File.read(agents_path, encoding: "UTF-8")
  if agents.lines.length > AGENTS_LINE_BUDGET
    errors << "AGENTS.md has #{agents.lines.length} lines (budget #{AGENTS_LINE_BUDGET}); move domain rules into the owning skill"
  end
  domain_sections = agents.scan(/^## (.+ changes)\s*$/).flatten - REPOSITORY_CHANGE_SECTIONS
  errors << "AGENTS.md contains domain change sections that belong in skills: #{domain_sections.join(", ")}" unless domain_sections.empty?
end

expected_inventory = {
  "Skills" => skill_count,
  "Implementation patterns" => pattern_count,
  "Evaluation cases" => evaluation_count,
  "Dedicated system/contract tests" => system_test_count
}
expected_inventory.each do |label, count|
  pattern = /\| #{Regexp.escape(label)} \| \*\*(\d+)\*\* \|/
  matches = readme.scan(pattern).flatten.map(&:to_i)
  errors << "README #{label} documentation is missing" if matches.empty?
  errors << "README #{label} count drift: #{matches.inspect} != #{count}" unless matches.all? { |value| value == count }

  handoff_pattern = case label
  when "Skills" then /- (\d+) skills/
  when "Implementation patterns" then /- (\d+) implementation patterns/
  when "Evaluation cases" then /- (\d+) evaluation cases/
  when "Dedicated system/contract tests" then /- (\d+) system\/contract tests/
  end
  handoff_matches = handoff.scan(handoff_pattern).flatten.map(&:to_i)
  errors << "IMPLEMENTATION_HANDOFF.md #{label} count drift: #{handoff_matches.inspect} != #{count}" unless handoff_matches.all? { |value| value == count } && !handoff_matches.empty?
end

manifest_skill_count = manifest.fetch("skills").length
errors << "manifest skill count #{manifest_skill_count} != filesystem #{skill_count}" unless manifest_skill_count == skill_count

puts "Documentation consistency audit"
puts "  latest changelog iteration: #{latest_changelog}"
puts "  README milestone: #{readme_milestone}"
puts "  handoff milestone: #{handoff_milestones.join(", ")}"
puts "  skills: #{skill_count}"
puts "  implementation patterns: #{pattern_count}"
puts "  evaluation cases: #{evaluation_count}"
puts "  system tests: #{system_test_count}"

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} documentation consistency error(s)"
end

puts "Documentation consistency audit passed."
