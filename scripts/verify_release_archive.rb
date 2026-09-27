#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "optparse"
require "tmpdir"

options = {check_files: false}
OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/verify_release_archive.rb ARCHIVE [options]"
  opts.on("--check-files", "Extract and verify every recorded release file") { options[:check_files] = true }
end.parse!

archive = File.expand_path(ARGV.fetch(0) { abort "release archive is required" })
abort "release archive not found: #{archive}" unless File.file?(archive)

errors = []
unless File.basename(archive).match?(%r{\Aruby-agent-skills-v[^/]+\.tar\.gz\z})
  errors << "archive filename must be ruby-agent-skills-vX.Y.Z.tar.gz"
end

Dir.mktmpdir("ruby-agent-skills-release-verify") do |tmp|
  listing, list_err, list_status = Open3.capture3("tar", "-tvzf", archive)
  errors << "unable to inspect archive: #{list_err}" unless list_status.success?

  if list_status.success?
    listing.each_line do |line|
      mode = line[0]
      path = line.split(/\s+/, 8).last.to_s.strip
      errors << "unsafe archive entry type: #{line.strip}" unless ["-", "d"].include?(mode)
      errors << "unsafe archive entry: #{path}" if path.start_with?("/") || path.split("/").include?("..")
    end
  end

  extract = File.join(tmp, "extract")
  FileUtils.mkdir_p(extract)
  _out, err, status = Open3.capture3("tar", "-xzf", archive, "-C", extract)
  errors << "archive extraction failed: #{err}" unless status.success?

  if status.success?
    roots = Dir[File.join(extract, "ruby-agent-skills-*")]
    if roots.length != 1 || !File.directory?(roots.first)
      errors << "archive must contain exactly one top-level ruby-agent-skills-vX.Y.Z directory"
    else
      root = roots.first
      metadata_path = File.join(root, "RELEASE.json")
      if !File.file?(metadata_path)
        errors << "release metadata RELEASE.json is missing"
      else
        begin
          release = JSON.parse(File.read(metadata_path, encoding: "UTF-8"))
          errors << "release metadata protocol_version must be 1" unless release["protocol_version"].to_i == 1
          expected_version = File.basename(root).delete_prefix("ruby-agent-skills-")
          errors << "release metadata version does not match archive root" unless release["version"] == expected_version
          errors << "release metadata git_sha must be a commit SHA" unless release["git_sha"].to_s.match?(/\A[0-9a-f]{40}\z/)
          errors << "release metadata skills count must be positive" unless release["skills"].to_i.positive?
          errors << "release metadata patterns count must be non-negative" unless release["patterns"].to_i >= 0

          actual_skills = Dir[File.join(root, "skills", "*", "SKILL.md")].length
          actual_patterns = Dir[File.join(root, "patterns", "**", "*.md")].reject { |p| p.end_with?("/README.md") }.length
          errors << "release metadata skills count does not match archive contents" unless release["skills"].to_i == actual_skills
          errors << "release metadata patterns count does not match archive contents" unless release["patterns"].to_i == actual_patterns

          files = release["files"]
          errors << "release metadata file inventory is missing" unless files.is_a?(Hash)

          if files.is_a?(Hash)
            files.each do |relative, metadata|
              target = File.join(root, relative)
              unless target.start_with?(root + File::SEPARATOR) || target == root
                errors << "release metadata path escapes archive root: #{relative}"
                next
              end
              unless File.file?(target)
                errors << "release metadata file is missing: #{relative}"
                next
              end
              if options[:check_files]
                expected_bytes = metadata["bytes"].to_i
                expected_sha = metadata["sha256"].to_s
                errors << "release metadata bytes mismatch: #{relative}" unless File.size(target) == expected_bytes
                errors << "release metadata SHA-256 mismatch: #{relative}" unless Digest::SHA256.file(target).hexdigest == expected_sha
              end
            end
          end
        rescue JSON::ParserError => e
          errors << "release metadata is invalid: #{e.message}"
        end
      end
    end
  end
end

if errors.any?
  errors.each { |error| warn "ERROR: #{error}" }
  abort "#{errors.length} release archive verification error(s)"
end

puts "Release archive verification"
puts "  archive: #{archive}"
puts "  files: #{options[:check_files] ? "verified" : "listing inspected"}"
puts "Release archive verification passed."
