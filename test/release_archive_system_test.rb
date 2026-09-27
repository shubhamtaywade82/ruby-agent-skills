# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

class ReleaseArchiveSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  BUILDER = File.join(ROOT, "scripts", "build_release_archive.rb")
  INSTALLER = File.join(ROOT, "bin", "install")

  VERSION = "v9.9.9-test"
  ARCHIVE_DIR = "ruby-agent-skills-#{VERSION}".freeze

  def manifest
    YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"), permitted_classes: [], aliases: false)
  end

  def expected_skill_count
    manifest.fetch("skills").length
  end

  def git_sha
    out, _err, status = Open3.capture3("git", "-C", ROOT, "rev-parse", "HEAD")
    raise "git rev-parse failed" unless status.success?

    out.strip
  end

  def build_archive(output_dir)
    out, err, status = Open3.capture3(
      RbConfig.ruby, BUILDER,
      "--version", VERSION,
      "--output", output_dir,
      chdir: ROOT
    )

    assert status.success?, "#{out}\n#{err}"
    File.join(output_dir, "ruby-agent-skills-#{VERSION}.tar.gz")
  end

  def install_from(extracted, project)
    Open3.capture3(
      { "RUBY_AGENT_SKILLS_REPO" => extracted },
      "bash", INSTALLER,
      "--scope", "project",
      "--agent", "agents",
      "--project", project,
      chdir: ROOT
    )
  end

  def test_archive_builds_with_provenance_and_checksum
    Dir.mktmpdir("release-archive") do |dir|
      archive = build_archive(dir)

      assert File.file?(archive)
      assert File.file?(File.join(dir, "SHA256SUMS"))
      assert File.file?(File.join(dir, "release-notes.md"))

      sums = File.read(File.join(dir, "SHA256SUMS"), encoding: "UTF-8")
      recorded = sums[/\A([0-9a-f]{64})  /, 1]
      require "digest"

      assert_equal Digest::SHA256.file(archive).hexdigest, recorded

      Dir.mktmpdir("release-extract") do |extracted|
        _out, err, status = Open3.capture3("tar", "-xzf", archive, "-C", extracted)

        assert status.success?, err

        archive_root = File.join(extracted, ARCHIVE_DIR)

        assert File.directory?(archive_root), "archive must extract into #{ARCHIVE_DIR}/"

        release = JSON.parse(File.read(File.join(archive_root, "RELEASE.json"), encoding: "UTF-8"))

        assert_equal VERSION, release.fetch("version")
        assert_equal git_sha, release.fetch("git_sha")
        assert_equal expected_skill_count, release.fetch("skills")

        %w[
          AGENTS.md LICENSE README.md CHANGELOG.md SECURITY.md CONTRIBUTING.md
          skill-manifest.yml router/ROUTING.md docs/SKILL_CONTRACT.md
          bin/install bin/skill-pack-verify bin/skill-pack-doctor bin/stack-minimality
        ].each do |path|
          assert File.file?(File.join(archive_root, path)), "archive missing #{path}"
        end
        assert File.file?(File.join(archive_root, "skills", "ruby-clean-code", "SKILL.md"))
        assert !File.exist?(File.join(archive_root, ".git")), "archive must not ship git history"
      end
    end
  end

  def test_offline_install_from_extracted_archive_records_release_provenance
    Dir.mktmpdir("release-archive") do |dir|
      archive = build_archive(dir)

      Dir.mktmpdir("release-extract") do |extracted|
        _out, err, status = Open3.capture3("tar", "-xzf", archive, "-C", extracted)

        assert status.success?, err

        project = File.join(dir, "project")
        FileUtils.mkdir_p(project)
        archive_root = File.join(extracted, ARCHIVE_DIR)
        out, err, status = install_from(archive_root, project)

        assert status.success?, "#{out}\n#{err}"

        target = File.join(project, ".agents", "skills")
        metadata = JSON.parse(File.read(File.join(target, ".ruby-agent-skills", "INSTALLATION.json"), encoding: "UTF-8"))

        assert_equal VERSION, metadata.dig("source", "requested_ref")
        assert_equal git_sha, metadata.dig("source", "resolved_git_sha")
        assert_equal expected_skill_count, metadata.fetch("inventory").fetch("skills")

        verify = File.join(target, ".ruby-agent-skills", "skill-pack-verify")
        vout, verr, vstatus = Open3.capture3(RbConfig.ruby, verify, "--root", target)

        assert vstatus.success?, "#{vout}\n#{verr}"
      end
    end
  end

  def test_archive_build_is_reproducible
    Dir.mktmpdir("release-archive") do |dir|
      build_archive(dir)
      require "digest"
      first = Digest::SHA256.file(File.join(dir, "ruby-agent-skills-#{VERSION}.tar.gz")).hexdigest
      build_archive(dir)
      second = Digest::SHA256.file(File.join(dir, "ruby-agent-skills-#{VERSION}.tar.gz")).hexdigest

      assert_equal first, second
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "test/release_archive_system_test.rb"
  end
end
