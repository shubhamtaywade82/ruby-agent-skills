#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "yaml"

module FrameworkDriftAudit
  REQUIRED_FIELDS = %w[
    framework status version symbol match replacement source_url source_section
  ].freeze
  RUBY_FENCE = /\A\x60\x60\x60(?:ruby|rb)\s*\z/
  END_FENCE = /\A\x60\x60\x60\s*\z/
  SUPPRESSION = /\A\s*#\s*framework-drift:\s*allow\s+(\S+)(?:\s|\z)/

  module_function

  def parse_registry(path)
    YAML.safe_load(
      File.read(path, encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
  end

  def validate_registry(entries)
    entries.each_with_object([]) do |(id, entry), errors|
      errors.concat(validate_entry(id, entry))
    end
  end

  def validate_entry(id, entry)
    return ["entry #{id} must be a mapping"] unless entry.is_a?(Hash)

    errors = missing_field_errors(id, entry)
    errors << invalid_match_error(id, entry)
    errors << "entry #{id} source_url must be HTTPS" unless https_source?(entry)
    errors.compact
  end

  def missing_field_errors(id, entry)
    REQUIRED_FIELDS.filter_map do |field|
      "entry #{id} missing #{field}" if entry[field].to_s.strip.empty?
    end
  end

  def invalid_match_error(id, entry)
    Regexp.new(entry.fetch("match"))
    nil
  rescue RegexpError => e
    "entry #{id} has invalid match: #{e.message}"
  end

  def https_source?(entry)
    entry["source_url"].to_s.start_with?("https://")
  end

  def scan(root:, scan_roots:, entries:)
    scan_roots.flat_map do |relative_root|
      absolute_root = File.join(root, relative_root)
      next [] unless Dir.exist?(absolute_root)

      Dir[File.join(absolute_root, "**", "*.md")].flat_map do |path|
        scan_file(path: path, root: root, entries: entries)
      end
    end
  end

  def scan_file(path:, root:, entries:)
    lines = File.readlines(path, encoding: "UTF-8")
    extract_ruby_blocks(lines).flat_map do |start_line, code_lines|
      scan_block(
        path: path,
        root: root,
        start_line: start_line,
        code_lines: code_lines,
        entries: entries
      )
    end
  end

  def extract_ruby_blocks(lines)
    blocks = []
    in_ruby = false
    block_start = nil
    block_lines = []

    lines.each_with_index do |line, index|
      if !in_ruby && line.match?(RUBY_FENCE)
        in_ruby = true
        block_start = index + 2
        block_lines = []
      elsif in_ruby && line.match?(END_FENCE)
        blocks << [block_start, block_lines]
        in_ruby = false
      elsif in_ruby
        block_lines << line
      end
    end

    blocks
  end

  def scan_block(path:, root:, start_line:, code_lines:, entries:)
    suppressed = code_lines.filter_map do |line|
      match = line.match(SUPPRESSION)
      match && match[1]
    end
    relative = path.delete_prefix("#{root}/")

    entries.flat_map do |id, entry|
      next [] if suppressed.include?(id)

      matches_for_entry(code_lines, entry).map do |offset|
        finding_message(
          relative: relative,
          line: start_line + offset,
          id: id,
          entry: entry
        )
      end
    end
  end

  def matches_for_entry(code_lines, entry)
    matcher = Regexp.new(entry.fetch("match"))
    code_lines.each_with_index.filter_map do |line, offset|
      offset if matcher.match?(line)
    end
  end

  def finding_message(relative:, line:, id:, entry:)
    format(
      "%<relative>s:%<line>d: framework drift %<id>s "       "(%<status>s Rails %<version>s) uses %<symbol>s; "       "replace with %<replacement>s",
      relative: relative,
      line: line,
      id: id,
      status: entry.fetch("status"),
      version: entry.fetch("version"),
      symbol: entry.fetch("symbol"),
      replacement: entry.fetch("replacement")
    )
  end
end

ROOT = File.expand_path("..", __dir__)
options = { root: ROOT, registry: File.join(ROOT, "framework-drift.yml") }

OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/audit_framework_drift.rb [--root PATH] [--registry PATH]"
  opts.on("--root PATH", "Repository root to scan") do |value|
    options[:root] = File.expand_path(value)
  end
  opts.on("--registry PATH", "Framework drift registry") do |value|
    options[:registry] = File.expand_path(value)
  end
end.parse!

abort "missing registry: #{options[:registry]}" unless File.file?(options[:registry])

registry = FrameworkDriftAudit.parse_registry(options.fetch(:registry))
entries = registry.fetch("entries")
scan_roots = registry.fetch("policy").fetch("scan_roots")
errors = FrameworkDriftAudit.validate_registry(entries)
errors.concat(
  FrameworkDriftAudit.scan(
    root: options.fetch(:root),
    scan_roots: scan_roots,
    entries: entries
  )
)

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} framework drift finding(s)"
end

puts format(
  "Framework drift audit passed: %<entries>d registry entries scanned across %<roots>d roots.",
  entries: entries.length,
  roots: scan_roots.length
)