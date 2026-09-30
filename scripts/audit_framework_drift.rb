#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "yaml"

ROOT = File.expand_path("..", __dir__)
options = { root: ROOT, registry: File.join(ROOT, "framework-drift.yml") }

OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/audit_framework_drift.rb [--root PATH] [--registry PATH]"
  opts.on("--root PATH", "Repository root to scan") { |value| options[:root] = File.expand_path(value) }
  opts.on("--registry PATH", "Framework drift registry") { |value| options[:registry] = File.expand_path(value) }
end.parse!

abort "missing registry: #{options[:registry]}" unless File.file?(options[:registry])

registry = YAML.safe_load(
  File.read(options[:registry], encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
)
entries = registry.fetch("entries")
roots = registry.fetch("policy").fetch("scan_roots")

errors = []

entries.each do |id, entry|
  unless entry.is_a?(Hash)
    errors << "entry #{id} must be a mapping"
    next
  end

  %w[framework status version symbol match replacement source_url source_section].each do |field|
    errors << "entry #{id} missing #{field}" if entry[field].to_s.strip.empty?
  end

  begin
    Regexp.new(entry.fetch("match"))
  rescue RegexpError => e
    errors << "entry #{id} has invalid match: #{e.message}"
  end

  errors << "entry #{id} source_url must be HTTPS" unless entry["source_url"].to_s.start_with?("https://")
end

ruby_fence = /^\x60\x60\x60(?:ruby|rb)\s*$/
end_fence = /^\x60\x60\x60\s*$/

roots.each do |relative_root|
  root = File.join(options[:root], relative_root)
  next unless Dir.exist?(root)

  Dir[File.join(root, "**", "*.md")].sort.each do |path|
    lines = File.readlines(path, encoding: "UTF-8")
    in_ruby = false
    block_start = nil
    block_lines = []

    lines.each_with_index do |line, index|
      if !in_ruby && line.match?(ruby_fence)
        in_ruby = true
        block_start = index + 1
        block_lines = []
        next
      end

      if in_ruby && line.match?(end_fence)
        entries.each do |id, entry|
          next unless entry.is_a?(Hash)

          suppression = block_lines.any? do |block_line|
            block_line.match?(/^\s*#\s*framework-drift:\s*allow\s+#{Regexp.escape(id)}(?:\s|$)/)
          end
          next if suppression

          matcher = Regexp.new(entry.fetch("match"))
          block_lines.each_with_index do |block_line, offset|
            next unless matcher.match?(block_line)

            relative = path.delete_prefix(options[:root] + "/")
            errors << "#{relative}:#{block_start + offset}: framework drift #{id} (#{entry.fetch("status")} Rails #{entry.fetch("version")}) uses #{entry.fetch("symbol")}; replace with #{entry.fetch("replacement")}"
          end
        end

        in_ruby = false
        block_start = nil
        block_lines = []
        next
      end

      block_lines << line if in_ruby
    end
  end
end

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} framework drift finding(s)"
end

puts "Framework drift audit passed: #{entries.length} registry entries scanned across #{roots.length} roots."
