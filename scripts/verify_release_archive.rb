#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "optparse"
require "tmpdir"
require "yaml"

options = { checksums: nil }
OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/verify_release_archive.rb ARCHIVE [--checksums SHA256SUMS]"
  opts.on("--checksums PATH", "Verify the archive against a published SHA256SUMS file") { |v| options[:checksums] = File.expand_path(v) }
end.parse!

archive = File.expand_path(ARGV.fetch(0) { abort "release archive is required" })
abort "release archive not found: #{archive}" unless File.file?(archive)

errors = []

if options[:checksums]
  sums = options[:checksums]
  if File.file?(sums)
    expected = File.readlines(sums, chomp: true).find { |line| line.end_with?("  #{File.basename(archive)}") }
    if expected
      expected_sha = expected.split.first
      actual_sha = Digest::SHA256.file(archive).hexdigest
      errors << "archive SHA-256 mismatch" unless expected_sha == actual_sha
    else
      errors << "published checksum entry missing"
    end
  else
    errors << "checksum file not found: #{sums}"
  end
end

Dir.mktmpdir("ruby-agent-skills-release-verify") do |root|
  extract = File.join(root, "extract")
  FileUtils.mkdir_p(extract)

  _stdout, stderr, status = Open3.capture3("tar", "-xzf", archive, "-C", extract)
  errors << "archive extraction failed: #{stderr}" unless status.success?
  next unless errors.empty?

  entries = Dir.children(extract)
  errors << "archive must contain exactly one top-level directory" unless entries.length == 1 && File.directory?(File.join(extract, entries.first))

  archive_root = File.join(extract, entries.first.to_s)
  version_match = File.basename(archive).match(/\Aruby-agent-skills-(v[^.]+(?:\.[^.]+)*?(?:-[0-9A-Za-z][0-9A-Za-z.-]*)?)\.tar\.gz\z/)
  release = File.join(archive_root, "RELEASE.json")

  unless File.file?(release)
    errors << "RELEASE.json is missing"
    next
  end

  begin
    metadata = JSON.parse(File.read(release, encoding: "UTF-8"))
    version = metadata.fetch("version")
    errors << "archive version directory mismatch" unless File.basename(archive_root) == "ruby-agent-skills-#{version}"
    errors << "archive filename/version mismatch" if version_match && version != version_match[1]
    errors << "invalid release git SHA" unless metadata.fetch("git_sha").match?(/\A[0-9a-f]{40}\z/)
    errors << "skill inventory mismatch" unless metadata.fetch("skills") == YAML.safe_load(File.read(File.join(archive_root, "skill-manifest.yml")), permitted_classes: [], aliases: false).fetch("skills").length
    pattern_count = Dir[File.join(archive_root, "patterns", "**", "*.md")].reject { |p| p.end_with?("/README.md") }.length
    errors << "pattern inventory mismatch" unless metadata.fetch("patterns") == pattern_count
  rescue JSON::ParserError, KeyError, TypeError, Errno::ENOENT => e
    errors << "invalid RELEASE.json: #{e.message}"
  end

  required = %w[
    AGENTS.md CHANGELOG.md CONTRIBUTING.md LICENSE README.md SECURITY.md
    bin/install bin/skill-pack-doctor bin/skill-pack-verify bin/stack-minimality
    docs/SKILL_CONTRACT.md router/ROUTING.md skill-manifest.yml RELEASE.json
  ]
  required.each { |path| errors << "missing release path: #{path}" unless File.file?(File.join(archive_root, path)) }
  %w[skills patterns].each { |dir| errors << "missing release directory: #{dir}" unless File.directory?(File.join(archive_root, dir)) }

  escaped = Dir.glob(File.join(archive_root, "**", "*"), File::FNM_DOTMATCH).any? do |path|
    File.symlink?(path) || !File.expand_path(path).start_with?("#{File.expand_path(archive_root)}/")
  end
  errors << "archive contains unsafe path or symlink" if escaped
end

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} release archive verification error(s)"
end

puts "Release archive verification"
puts "  archive: #{archive}"
puts "  RELEASE.json: verified"
puts "  inventory: verified"
puts "  required agent-facing surface: verified"
puts "Release archive verification passed."
