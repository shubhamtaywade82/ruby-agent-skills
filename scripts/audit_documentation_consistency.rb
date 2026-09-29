#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "yaml"

default_root = File.expand_path("..", __dir__)
options = { root: default_root }

OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/audit_documentation_consistency.rb [--root PATH]"
  opts.on("--root PATH", "Repository root to audit") { |value| options[:root] = File.expand_path(value) }
end.parse!

root = options[:root]
readme_path = File.join(root, "README.md")
changelog_path = File.join(root, "CHANGELOG.md")
handoff_path = File.join(root, "docs", "IMPLEMENTATION_HANDOFF.md")
iterations_path = File.join(root, "docs", "ITERATIONS.md")
manifest_path = File.join(root, "skill-manifest.yml")
routing_campaign_path = File.join(root, "router", "ROUTING_CAMPAIGN.yml")
routing_campaign = {}
if File.file?(routing_campaign_path)
  routing_campaign = YAML.safe_load(
    File.read(routing_campaign_path, encoding: "UTF-8"),
    permitted_classes: [],
    aliases: false
  )
end

[readme_path, changelog_path, handoff_path, iterations_path, manifest_path].each do |path|
  abort "missing documentation audit input: #{path}" unless File.file?(path)
end

readme = File.read(readme_path, encoding: "UTF-8")
changelog = File.read(changelog_path, encoding: "UTF-8")
handoff = File.read(handoff_path, encoding: "UTF-8")
iterations = File.read(iterations_path, encoding: "UTF-8")
manifest = YAML.safe_load(File.read(manifest_path, encoding: "UTF-8"), permitted_classes: [], aliases: false)

skill_count = Dir[File.join(root, "skills", "*", "SKILL.md")].length
pattern_count = Dir[File.join(root, "patterns", "**", "*.md")].reject { |path| path.end_with?("/README.md") }.length
evaluation_count = Dir[File.join(root, "evals", "**", "*.yml")].sum do |path|
  data = YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
  Array(data.fetch("cases")).length
end
system_test_count = Dir[File.join(root, "test", "*_system_test.rb")].length

latest_changelog = changelog[/^## Iteration (\d+)/, 1].to_i
milestone = iterations[/Current milestone:\*\* Iteration (\d+)/, 1].to_i
iteration_numbers = iterations.scan(/^## Iteration (\d+) /).flatten.map(&:to_i)
handoff_milestones = handoff.scan(/complete through Iteration (\d+)/).flatten.map(&:to_i).uniq

routing_execution = routing_campaign.fetch("execution", {})
routing_case_file = File.join(root, routing_campaign.fetch("cases_file", ""))
routing_case_count = 0
if File.file?(routing_case_file)
  routing_cases = YAML.safe_load(
    File.read(routing_case_file, encoding: "UTF-8"),
    permitted_classes: [],
    aliases: false
  )
  routing_case_count = Array(routing_cases.fetch("cases")).length
end
routing_repetitions = routing_execution.fetch("repetitions", 0).to_i
routing_expected_runs = routing_case_count * routing_repetitions

errors = []
errors << "docs/ITERATIONS.md current milestone #{milestone} != latest changelog #{latest_changelog}" unless milestone == latest_changelog
errors << "docs/ITERATIONS.md has no section for Iteration #{latest_changelog}" unless iteration_numbers.include?(latest_changelog)
errors << "docs/ITERATIONS.md sections are not in ascending order" unless iteration_numbers == iteration_numbers.sort
# The README describes the current system; iteration history lives in docs/ITERATIONS.md.
readme_iteration_lines = readme.lines.each_with_index.select { |line, _| line.match?(/\bIteration \d+/) }.map { |_, index| index + 1 }
errors << "README.md mentions iterations on lines #{readme_iteration_lines.join(", ")}; move history to docs/ITERATIONS.md" unless readme_iteration_lines.empty?
errors << "IMPLEMENTATION_HANDOFF.md status #{handoff_milestones.inspect} != latest changelog #{latest_changelog}" unless handoff_milestones == [latest_changelog]

if routing_expected_runs.positive?
  documented_routing = handoff[/The campaign is (\d+) public cases × (\d+) repetitions = (\d+) model decisions\./]
  expected_routing = "The campaign is #{routing_case_count} public cases × #{routing_repetitions} repetitions = #{routing_expected_runs} model decisions."
  errors << "public routing campaign run-count documentation drift: #{documented_routing.inspect} != #{expected_routing.inspect}" unless documented_routing == expected_routing
end

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

# RELEASE.md documents the shipped archive contents.
release_path = File.join(root, "RELEASE.md")
if File.file?(release_path)
  release = File.read(release_path, encoding: "UTF-8")
  { "skills" => [/(\d+) agent-executable skills/, skill_count],
    "patterns" => [/(\d+) implementation patterns/, pattern_count] }.each do |label, (pattern, count)|
    documented = release.scan(pattern).flatten.map(&:to_i)
    errors << "RELEASE.md #{label} count drift: #{documented.inspect} != #{count}" unless !documented.empty? && documented.all?(count)
  end
end

manifest_skill_count = manifest.fetch("skills").length
errors << "manifest skill count #{manifest_skill_count} != filesystem #{skill_count}" unless manifest_skill_count == skill_count

puts "Documentation consistency audit"
puts "  latest changelog iteration: #{latest_changelog}"
puts "  current milestone (docs/ITERATIONS.md): #{milestone}"
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
