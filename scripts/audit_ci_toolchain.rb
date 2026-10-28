#!/usr/bin/env ruby
# frozen_string_literal: true

# CI toolchain audit: every workflow must use actions/checkout, pinned to a
# full commit SHA with a version comment (the Autonomous Engineering Platform
# pinning policy, see .github/GOVERNANCE.md), and the pinned version must be
# Node 24-compatible (v5+). Bare version tags are rejected because a mutable
# tag is not a security boundary.

ROOT = File.expand_path("..", __dir__)
workflow_files = Dir[File.join(ROOT, ".github", "workflows", "*.yml")].sort

abort "no GitHub Actions workflow files found" if workflow_files.empty?

errors = []
checkout_usages = []

SHA_WITH_COMMENT = %r{actions/checkout@([0-9a-f]{40})\s*#\s*(v\d+(?:\.\d+){0,2})}.freeze
SHA_WITHOUT_COMMENT = %r{actions/checkout@([0-9a-f]{40})(?!\s*#)}.freeze
BARE_TAG = %r{actions/checkout@(v\d+(?:\.\d+){0,2})}.freeze

workflow_files.each do |path|
  rel = path.delete_prefix(ROOT + "/")
  text = File.read(path, encoding: "UTF-8")

  text.scan(SHA_WITH_COMMENT).each do |(_, version)|
    checkout_usages << [rel, version]
    major = version.delete_prefix("v").split(".").first.to_i
    errors << "#{rel}: actions/checkout must use Node 24-compatible v5+; found #{version}" if major < 5
  end

  errors << "#{rel}: actions/checkout SHA-pinned without a version comment" if text.match?(SHA_WITHOUT_COMMENT)

  text.scan(BARE_TAG).flatten.each do |version|
    errors << "#{rel}: actions/checkout must be SHA-pinned with a version comment; found bare #{version}"
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
