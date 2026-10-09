#!/usr/bin/env ruby
# frozen_string_literal: true

# Data catalog audit.
#
# Each data/*/tools.yml catalog is a small registry that a consuming repository
# reads when choosing tooling. Nothing else in this repository reads their
# contents - the owning system tests only assert that the file exists - so this
# audit is the sole check that their structure, ownership, and uniqueness hold.
#
# Three classes of defect are checked:
#   - structure: required top-level keys, a category on every tool, a usable
#     selection rule list;
#   - ownership: every catalog names an owner that resolves to an installed skill;
#   - uniqueness: no file contains a key that YAML would silently collapse, and no
#     tool key is defined with two different commands or gems across catalogs.
#
# A tool key appearing in more than one catalog is legitimate, not a defect: a
# generic command such as `bin/rails test` is filed once per domain with that
# domain's category, and those definitions agree. Only a disagreement between
# the definitions of the same key is an error.
#
# Usage:
#   ruby scripts/audit_data_catalogs.rb [--root PATH]

require "optparse"
require "yaml"

options = { root: File.expand_path("..", __dir__) }
OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/audit_data_catalogs.rb [--root PATH]"
  opts.on("--root PATH", "Repository root to audit") do |value|
    options[:root] = File.expand_path(value)
  end
end.parse!

ROOT = options[:root]
REQUIRED_TOP_LEVEL = %w[version source owner tools selection].freeze

# Returns the text under a top-level `tools:` key, or nil if absent. Used only
# to count raw key lines, since a duplicate key collapses during YAML parsing.
def tools_block(raw)
  start = raw.lines.index { |line| line.start_with?("tools:") }
  return nil unless start

  raw.lines[(start + 1)..].take_while { |line| !line.match?(/^[a-z]/) }.join
end

def check_top_level(data, rel, errors)
  missing = REQUIRED_TOP_LEVEL - data.keys
  return if missing.empty?

  errors << "#{rel}: missing top-level key(s): #{missing.join(', ')}"
end

def check_selection(data, rel, errors)
  rules = data.dig("selection", "rules")
  return if rules.is_a?(Array) && !rules.empty? &&
            rules.all? { |rule| rule.is_a?(String) && !rule.strip.empty? }

  errors << "#{rel}: selection.rules must be a non-empty list of non-empty strings"
end

def owner_resolved?(data, rel, errors)
  owner = data["owner"]
  return false unless owner.is_a?(String) && !owner.empty?
  return true if File.file?(File.join(ROOT, "skills", owner, "SKILL.md"))

  errors << "#{rel}: owner #{owner.inspect} has no skills/#{owner}/SKILL.md"
  false
end

def check_collapsed_keys(tools, raw, rel, errors)
  raw_count = tools_block(raw).to_s.scan(/^\s{2}[a-z0-9_-]+:\s*$/).size
  return if raw_count <= tools.size

  errors << "#{rel}: #{raw_count - tools.size} duplicate key(s) - YAML kept the last definition"
end

def check_spec(spec, name, rel, errors)
  unless spec.is_a?(Hash)
    errors << "#{rel}: tool #{name.inspect} must be a mapping"
    return nil
  end

  category = spec["category"]
  valid = category.is_a?(String) && !category.strip.empty?
  errors << "#{rel}: tool #{name.inspect} has no category" unless valid
  spec
end

def identity_for(spec)
  [spec["gem"], spec["command"]].compact.reject { |value| value.to_s.empty? }
end

# Returns [entries, identities, gems] for one catalog.
def collect_tools(tools, rel, errors)
  identities = []
  gems = []

  tools.each do |name, spec|
    next unless check_spec(spec, name, rel, errors)

    identities << [name, identity_for(spec)]
    gems << spec["gem"] if spec["gem"] && !spec["gem"].empty?
  end

  [tools.size, identities, gems]
end

def check_tools(tools, raw, rel, errors)
  unless tools.is_a?(Hash) && !tools.empty?
    errors << "#{rel}: tools must be a non-empty mapping"
    return [0, [], []]
  end

  check_collapsed_keys(tools, raw, rel, errors)
  collect_tools(tools, rel, errors)
end

errors = []
catalogs = Dir[File.join(ROOT, "data", "*", "tools.yml")]
errors << "no data/*/tools.yml catalogs found" if catalogs.empty?

seen_gems = Hash.new { |h, k| h[k] = [] }
identities = Hash.new { |h, k| h[k] = [] }
entry_count = 0
owned_count = 0

catalogs.each do |path|
  rel = path.delete_prefix("#{ROOT}/")
  raw = File.read(path, encoding: "UTF-8")

  begin
    data = YAML.safe_load(raw, permitted_classes: [], aliases: false)
  rescue Psych::Exception => e
    errors << "#{rel}: unparseable YAML (#{e.message.lines.first&.strip})"
    next
  end

  unless data.is_a?(Hash)
    errors << "#{rel}: top level must be a mapping"
    next
  end

  check_top_level(data, rel, errors)
  check_selection(data, rel, errors)
  owned_count += 1 if owner_resolved?(data, rel, errors)

  entries, found, gems = check_tools(data["tools"], raw, rel, errors)
  entry_count += entries
  found.each { |name, id| identities[name] |= id }
  gems.each { |gem| seen_gems[gem] << rel }
end

identities.each do |name, distinct|
  next if distinct.size < 2

  errors << "tool key #{name.inspect} has conflicting identifiers: #{distinct.inspect}"
end

seen_gems.each do |gem, where|
  errors << "gem #{gem.inspect} registered in: #{where.join(', ')}" if where.size > 1
end

puts "Data catalog audit"
puts "  catalogs: #{catalogs.size}"
puts "  tool entries: #{entry_count}"
puts "  catalogs with a resolvable owner: #{owned_count}"

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} data catalog error(s)"
end

puts "Data catalog audit passed."
