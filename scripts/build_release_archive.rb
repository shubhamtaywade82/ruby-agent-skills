#!/usr/bin/env ruby
# frozen_string_literal: true

# Builds the distributable Ruby Agent Skills release archive.
#
# The archive carries the complete agent-facing surface (skills, patterns,
# manifest, routing contract, installer, verifier, doctor, and public
# metadata) plus a RELEASE.json provenance record, so consumers can install
# offline from the extracted directory with `bash bin/install`.
#
# Usage:
#   ruby scripts/build_release_archive.rb --version v1.0.0
#   ruby scripts/build_release_archive.rb --version v1.0.0 --output dist
#   ruby scripts/build_release_archive.rb --version v1.0.0 --self-test
#
# Outputs (inside --output, default dist/):
#   ruby-agent-skills-<version>.tar.gz   - the release archive
#   SHA256SUMS                           - checksums for every artifact
#   release-notes.md                     - GitHub Release notes body

require "digest"
require "fileutils"
require "json"
require "open3"
require "optparse"
require "tmpdir"
require "yaml"

ROOT = File.expand_path("..", __dir__)

options = { version: nil, output: File.join(ROOT, "dist"), self_test: false }
OptionParser.new do |opts|
  opts.banner = "usage: ruby scripts/build_release_archive.rb --version vX.Y.Z [--output DIR] [--self-test]"
  opts.on("--version V", "Release version tag (e.g. v1.0.0)") { |v| options[:version] = v }
  opts.on("--output DIR", "Output directory (default: dist)") { |v| options[:output] = File.expand_path(v) }
  opts.on("--self-test", "Extract the archive and verify an offline install") { options[:self_test] = true }
end.parse!

abort "--version is required (e.g. v1.0.0)" if options[:version].to_s.empty?
version = options[:version]
abort "version must look like vX.Y.Z (optionally with a -rc.1 style pre-release): #{version}" unless version =~ /\Av\d+(\.\d+){0,3}(-[0-9A-Za-z][0-9A-Za-z.-]*)?\z/

# Public agent-facing surface shipped in the archive.
SHIPPED_PATHS = %w[
  AGENTS.md
  CHANGELOG.md
  CONTRIBUTING.md
  LICENSE
  README.md
  SECURITY.md
  bin/install
  bin/skill-pack-doctor
  bin/skill-pack-verify
  bin/stack-minimality
  docs/SKILL_CONTRACT.md
  router/ROUTING.md
  skill-manifest.yml
].freeze
SHIPPED_DIRS = %w[skills patterns].freeze

SHIPPED_PATHS.each do |path|
  abort "missing release file: #{path}" unless File.file?(File.join(ROOT, path))
end
SHIPPED_DIRS.each do |dir|
  abort "missing release directory: #{dir}" unless File.directory?(File.join(ROOT, dir))
end

manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"), permitted_classes: [], aliases: false)
skill_count = manifest.fetch("skills").length
pattern_count = Dir[File.join(ROOT, "patterns", "**", "*.md")].reject { |p| p.end_with?("/README.md") }.length

git_sha = Dir.chdir(ROOT) do
  out, _err, status = Open3.capture3("git", "rev-parse", "HEAD")
  abort "unable to resolve git HEAD" unless status.success?
  out.strip
end

inventory = {
  "protocol_version" => 1,
  "version" => version,
  "git_sha" => git_sha,
  "skills" => skill_count,
  "patterns" => pattern_count
}

output_dir = options[:output]
FileUtils.mkdir_p(output_dir)
archive_name = "ruby-agent-skills-#{version}.tar.gz"
archive_path = File.join(output_dir, archive_name)

Dir.mktmpdir("ruby-agent-skills-release") do |stage|
  archive_root = File.join(stage, "ruby-agent-skills-#{version}")
  FileUtils.mkdir_p(archive_root)
  SHIPPED_PATHS.each do |path|
    dest = File.join(archive_root, path)
    FileUtils.mkdir_p(File.dirname(dest))
    FileUtils.cp(File.join(ROOT, path), dest)
  end
  SHIPPED_DIRS.each do |dir|
    FileUtils.cp_r(File.join(ROOT, dir), File.join(archive_root, dir))
  end

  # File-level provenance is computed from the staged tree so it describes
  # exactly what ships, including anything cp_r picked up from the source.
  staged_prefix = "#{archive_root}/"
  file_inventory = Dir.glob(File.join(archive_root, "**", "*"), File::FNM_DOTMATCH)
                      .select { |path| File.file?(path) }
                      .map { |path| path.delete_prefix(staged_prefix) }
                      .sort
                      .to_h do |path|
                        staged = File.join(archive_root, path)
                        [path, { "bytes" => File.size(staged), "sha256" => Digest::SHA256.file(staged).hexdigest }]
                      end

  release = inventory.merge("files" => file_inventory)
  File.write(File.join(archive_root, "RELEASE.json"), JSON.pretty_generate(release) + "\n", encoding: "UTF-8")

  # Deterministic archive: sorted entries, fixed mtime/owner for reproducible builds.
  tar_args = [
    "--sort=name", "--mtime=@0", "--owner=0", "--group=0", "--numeric-owner",
    "--format=gnu", "-czf", archive_path, "-C", stage, "ruby-agent-skills-#{version}"
  ]
  out, err, status = Open3.capture3("tar", *tar_args)
  abort "tar failed: #{err}" unless status.success?
  warn out unless out.empty?
end

archive_sha256 = Digest::SHA256.file(archive_path).hexdigest
archive_bytes = File.size(archive_path)

notes = <<~NOTES
  # Ruby Agent Skills #{version}

  A release of **agent-executable Ruby and Ruby on Rails engineering knowledge**: #{skill_count} skills, #{pattern_count} implementation patterns, a routing contract, and a verified installer.

  Source commit: `#{git_sha}`

  ## Install from this archive (offline)

  Extract the archive, then install into your agent's skill layout:

      tar xzf #{archive_name}
      cd ruby-agent-skills-#{version}
      bash bin/install --agent agents        # or: codex | claude | copilot

  Verify the installed pack:

      ruby .agents/skills/.ruby-agent-skills/skill-pack-verify --root .agents/skills
      ruby bin/skill-pack-doctor --root .agents/skills

  ## Install from git

      bash -c "$(curl -fsSL https://raw.githubusercontent.com/shubhamtaywade82/ruby-agent-skills/#{version}/bin/install)" -- --ref #{version} --agent claude

  ## Integrity

  Archive: `#{archive_name}`
  SHA-256: `#{archive_sha256}`
  Size: #{archive_bytes} bytes

  ## Verification

  Every release passes the full repository validation suite (`bin/validate`): skill, pattern, evaluation, provenance-hygiene, routing, CI-toolchain, repository-completeness, benchmark-quality, and release-readiness audits plus the dedicated system tests.
NOTES
notes_path = File.join(output_dir, "release-notes.md")
File.write(notes_path, notes, encoding: "UTF-8")

sums_path = File.join(output_dir, "SHA256SUMS")
File.write(sums_path, "#{archive_sha256}  #{archive_name}\n", encoding: "UTF-8")

puts "Release archive built"
puts "  version:   #{version}"
puts "  git sha:   #{git_sha}"
puts "  skills:    #{skill_count}"
puts "  patterns:  #{pattern_count}"
puts "  archive:   #{archive_path}"
puts "  sha256:    #{archive_sha256}"
puts "  bytes:     #{archive_bytes}"

if options[:self_test]
  Dir.mktmpdir("ruby-agent-skills-archive-test") do |test_root|
    extract_dir = File.join(test_root, "extracted")
    project_dir = File.join(test_root, "project")
    archive_root = File.join(extract_dir, "ruby-agent-skills-#{version}")
    FileUtils.mkdir_p(extract_dir)
    FileUtils.mkdir_p(project_dir)

    _out, err, status = Open3.capture3("tar", "-xzf", archive_path, "-C", extract_dir)
    abort "archive extraction failed: #{err}" unless status.success?

    installed_root = File.join(project_dir, ".agents", "skills")
    out, err, status = Open3.capture3(
      { "RUBY_AGENT_SKILLS_REPO" => archive_root },
      "bash", File.join(archive_root, "bin", "install"),
      "--scope", "project", "--agent", "agents", "--project", project_dir
    )
    abort "offline install failed:\n#{out}\n#{err}" unless status.success?

    verify = File.join(installed_root, ".ruby-agent-skills", "skill-pack-verify")
    out, err, status = Open3.capture3(RbConfig.ruby, verify, "--root", installed_root)
    abort "offline installation verification failed:\n#{out}\n#{err}" unless status.success?

    doctor = File.join(archive_root, "bin", "skill-pack-doctor")
    out, err, status = Open3.capture3({ "RUBY_AGENT_SKILLS_ROOT" => installed_root }, RbConfig.ruby, doctor, "--root", installed_root)
    abort "offline installation doctor failed:\n#{out}\n#{err}" unless status.success?

    release = JSON.parse(File.read(File.join(archive_root, "RELEASE.json"), encoding: "UTF-8"))
    abort "archive provenance mismatch" unless release["version"] == version && release["git_sha"] == git_sha

    puts "Offline archive self-test passed (install + verify + doctor from extracted archive)"
  end
end
