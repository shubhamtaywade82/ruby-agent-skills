#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("..", __dir__)
workflow_files = Dir[File.join(ROOT, ".github", "workflows", "*.yml")].sort

abort "no GitHub Actions workflow files found" if workflow_files.empty?

errors = []
checkout_usages = []

workflow_files.each do |path|
  text = File.read(path, encoding: "UTF-8")
  text.scan(/actions\/checkout@(v\d+(?:\.\d+){0,2})/).flatten.each do |version|
    checkout_usages << [path.delete_prefix(ROOT + "/"), version]
    major = version.delete_prefix("v").split(".").first.to_i
    errors << "#{path}: actions/checkout must use Node 24-compatible v5+; found #{version}" if major < 5
  end
end

errors << "no actions/checkout usage found in workflows" if checkout_usages.empty?

puts "CI toolchain audit"
checkout_usages.each { |path, version| puts "  #{path}: actions/checkout@#{version}" }

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} CI toolchain audit error(s)"
end

puts "CI toolchain audit passed."
