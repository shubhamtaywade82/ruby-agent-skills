#!/usr/bin/env ruby
# frozen_string_literal: true

# Independently verifies a built release archive without trusting the
# builder's self-test.
#
# Usage:
#   ruby scripts/verify_release_archive.rb dist/ruby-agent-skills-vX.Y.Z.tar.gz
#   ruby scripts/verify_release_archive.rb ARCHIVE --checksums dist/SHA256SUMS
#   ruby scripts/verify_release_archive.rb ARCHIVE --check-files
#
# Checks, in order:
#   1. optional published SHA-256 checksum of the archive itself;
#   2. tar listing safety before extraction (regular files/directories only,
#      no absolute or parent-traversal member names);
#   3. single top-level directory, RELEASE.json schema, version/filename
#      binding, skill/pattern inventory, required agent-facing surface;
#   4. no symlinks or paths escaping the extracted root;
#   5. RELEASE.json file-level provenance: every recorded file exists, and
#      with --check-files every file's byte size and SHA-256 match and no
#      unrecorded file is shipped.

require "digest"
require "fileutils"
require "json"
require "open3"
require "optparse"
require "tmpdir"
require "yaml"

PROTOCOL_VERSION = 1
REQUIRED_PATHS = %w[
  AGENTS.md CHANGELOG.md CONTRIBUTING.md LICENSE README.md SECURITY.md
  bin/install bin/skill-pack-doctor bin/skill-pack-verify bin/stack-minimality
  docs/SKILL_CONTRACT.md router/ROUTING.md skill-manifest.yml RELEASE.json
].freeze
REQUIRED_DIRS = %w[skills patterns].freeze
ARCHIVE_NAME = /\Aruby-agent-skills-(v\d+(?:\.\d+){0,3}(?:-[0-9A-Za-z][0-9A-Za-z.-]*)?)\.tar\.gz\z/

options = { checksums: nil, check_files: false }
OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/verify_release_archive.rb ARCHIVE [--checksums SHA256SUMS] [--check-files]"
  opts.on("--checksums PATH", "Verify the archive against a published SHA256SUMS file") { |v| options[:checksums] = File.expand_path(v) }
  opts.on("--check-files", "Verify every shipped file against RELEASE.json size/SHA-256 provenance") { options[:check_files] = true }
end.parse!

archive = File.expand_path(ARGV.fetch(0) { abort "release archive is required" })
abort "release archive not found: #{archive}" unless File.file?(archive)

errors = []
filename_version = File.basename(archive)[ARCHIVE_NAME, 1]

if options[:checksums]
  sums = options[:checksums]
  if File.file?(sums)
    expected = File.readlines(sums, chomp: true).find { |line| line.end_with?("  #{File.basename(archive)}") }
    if expected
      errors << "archive SHA-256 mismatch" unless expected.split.first == Digest::SHA256.file(archive).hexdigest
    else
      errors << "published checksum entry missing"
    end
  else
    errors << "checksum file not found: #{sums}"
  end
end

# Inspect member types and names before anything touches the filesystem.
listing, list_err, list_status = Open3.capture3("tar", "-tvzf", archive)
if list_status.success?
  listing.each_line do |line|
    # GNU tar verbose listing: MODE OWNER/GROUP SIZE DATE TIME NAME
    path = line.chomp.split(/\s+/, 6).last.to_s
    errors << "unsafe archive entry type: #{line.strip}" unless %w[- d].include?(line[0])
    errors << "unsafe archive entry: #{path}" if path.start_with?("/") || path.split("/").include?("..")
  end
else
  errors << "unable to inspect archive: #{list_err.strip}"
end

if errors.empty?
  Dir.mktmpdir("ruby-agent-skills-release-verify") do |tmp|
    extract = File.join(tmp, "extract")
    FileUtils.mkdir_p(extract)

    _stdout, stderr, status = Open3.capture3("tar", "-xzf", archive, "-C", extract, "--no-same-owner")
    unless status.success?
      errors << "archive extraction failed: #{stderr.strip}"
      next
    end

    entries = Dir.children(extract)
    unless entries.length == 1 && File.directory?(File.join(extract, entries.first))
      errors << "archive must contain exactly one top-level directory"
      next
    end

    archive_root = File.expand_path(File.join(extract, entries.first))
    archive_root_prefix = "#{archive_root}/"

    shipped = Dir.glob(File.join(archive_root, "**", "*"), File::FNM_DOTMATCH).reject do |path|
      # FNM_DOTMATCH yields literal "."/".." entries that collapse to a parent.
      [".", ".."].include?(File.basename(path))
    end
    if shipped.any? { |path| File.symlink?(path) || !File.expand_path(path).start_with?(archive_root_prefix) }
      errors << "archive contains unsafe path or symlink"
      next
    end

    REQUIRED_PATHS.each { |path| errors << "missing release path: #{path}" unless File.file?(File.join(archive_root, path)) }
    REQUIRED_DIRS.each { |dir| errors << "missing release directory: #{dir}" unless File.directory?(File.join(archive_root, dir)) }

    release_path = File.join(archive_root, "RELEASE.json")
    next unless File.file?(release_path)

    begin
      metadata = JSON.parse(File.read(release_path, encoding: "UTF-8"))
      raise TypeError, "RELEASE.json must be an object" unless metadata.is_a?(Hash)

      errors << "RELEASE.json protocol_version must be #{PROTOCOL_VERSION}" unless metadata["protocol_version"] == PROTOCOL_VERSION
      version = metadata.fetch("version")
      errors << "archive version directory mismatch" unless File.basename(archive_root) == "ruby-agent-skills-#{version}"
      errors << "archive filename/version mismatch" if filename_version && version != filename_version
      errors << "invalid release git SHA" unless metadata.fetch("git_sha").to_s.match?(/\A[0-9a-f]{40}\z/)

      manifest = YAML.safe_load(File.read(File.join(archive_root, "skill-manifest.yml"), encoding: "UTF-8"), permitted_classes: [], aliases: false)
      errors << "skill inventory mismatch" unless metadata.fetch("skills") == manifest.fetch("skills").length
      pattern_count = Dir[File.join(archive_root, "patterns", "**", "*.md")].reject { |p| p.end_with?("/README.md") }.length
      errors << "pattern inventory mismatch" unless metadata.fetch("patterns") == pattern_count

      files = metadata.fetch("files")
      raise TypeError, "RELEASE.json files must be an object" unless files.is_a?(Hash) && !files.empty?

      files.each do |relative, record|
        target = File.expand_path(relative.to_s, archive_root)
        unless target.start_with?(archive_root_prefix)
          errors << "release file record escapes archive root: #{relative}"
          next
        end
        unless File.file?(target)
          errors << "release file record missing from archive: #{relative}"
          next
        end
        next unless options[:check_files]

        unless record.is_a?(Hash) && record["bytes"].is_a?(Integer) && record["sha256"].to_s.match?(/\A[0-9a-f]{64}\z/)
          errors << "malformed release file record: #{relative}"
          next
        end
        errors << "release file bytes mismatch: #{relative}" unless File.size(target) == record["bytes"]
        errors << "release file SHA-256 mismatch: #{relative}" unless Digest::SHA256.file(target).hexdigest == record["sha256"]
      end

      if options[:check_files]
        shipped.select { |path| File.file?(path) }.map { |path| path.delete_prefix(archive_root_prefix) }.each do |relative|
          next if relative == "RELEASE.json"

          errors << "unrecorded file shipped in archive: #{relative}" unless files.key?(relative)
        end
      end
    rescue JSON::ParserError, KeyError, TypeError, NoMethodError, Errno::ENOENT, Psych::Exception => e
      errors << "invalid RELEASE.json: #{e.message}"
    end
  end
end

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} release archive verification error(s)"
end

puts "Release archive verification"
puts "  archive: #{archive}"
puts "  checksum: #{options[:checksums] ? "verified" : "not requested"}"
puts "  RELEASE.json: verified"
puts "  inventory: verified"
puts "  required agent-facing surface: verified"
puts "  file provenance: #{options[:check_files] ? "verified" : "recorded paths present"}"
puts "Release archive verification passed."
