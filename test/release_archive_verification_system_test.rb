# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class ReleaseArchiveVerificationSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  BUILDER = File.join(ROOT, "scripts", "build_release_archive.rb")
  VERIFIER = File.join(ROOT, "scripts", "verify_release_archive.rb")
  VERSION = "v9.9.9-verify"

  def build(dir)
    out, err, status = Open3.capture3(
      RbConfig.ruby, BUILDER, "--version", VERSION, "--output", dir, chdir: ROOT
    )
    assert status.success?, "#{out}\n#{err}"
    File.join(dir, "ruby-agent-skills-#{VERSION}.tar.gz")
  end

  def verify(archive, *args)
    Open3.capture3(RbConfig.ruby, VERIFIER, archive, *args, chdir: ROOT)
  end

  def test_standalone_verifier_validates_release_archive
    Dir.mktmpdir("release-verify") do |dir|
      archive = build(dir)
      out, err, status = verify(archive, "--check-files")
      assert status.success?, "#{out}\n#{err}"
      assert_includes out, "Release archive verification passed."
    end
  end

  def test_verifier_rejects_tampered_archive
    Dir.mktmpdir("release-verify") do |dir|
      archive = build(dir)
      tampered = File.join(dir, "tampered.tar.gz")
      File.binwrite(tampered, File.binread(archive) + "tampered")
      _out, err, status = verify(tampered, "--check-files")
      refute status.success?
      assert_includes err, "SHA-256 mismatch"
    end
  end

  def test_verifier_rejects_tampered_release_metadata
    Dir.mktmpdir("release-verify") do |dir|
      archive = build(dir)
      extract = File.join(dir, "extract")
      FileUtils.mkdir_p(extract)
      system("tar", "-xzf", archive, "-C", extract)
      metadata = File.join(extract, "ruby-agent-skills-#{VERSION}", "RELEASE.json")
      release = JSON.parse(File.read(metadata, encoding: "UTF-8"))
      release["skills"] = 1
      File.write(metadata, JSON.pretty_generate(release) + "\n", encoding: "UTF-8")
      tampered = File.join(dir, "tampered-metadata.tar.gz")
      system("tar", "-czf", tampered, "-C", extract, "ruby-agent-skills-#{VERSION}")
      _out, err, status = verify(tampered)
      refute status.success?
      assert_includes err, "release metadata"
    end
  end

  def test_verifier_rejects_path_traversal
    Dir.mktmpdir("release-verify") do |dir|
      malicious_root = File.join(dir, "ruby-agent-skills-#{VERSION}")
      FileUtils.mkdir_p(malicious_root)
      File.write(File.join(malicious_root, "RELEASE.json"), JSON.pretty_generate(
        "version" => VERSION, "git_sha" => "0" * 40, "skills" => 91, "patterns" => 431,
        "files" => {}
      ))
      FileUtils.mkdir_p(File.join(malicious_root, "nested"))
      File.symlink("/tmp", File.join(malicious_root, "nested", "escape"))
      archive = File.join(dir, "malicious.tar.gz")
      system("tar", "-czhf", archive, "-C", dir, "ruby-agent-skills-#{VERSION}")
      _out, err, status = verify(archive)
      refute status.success?
      assert_includes err, "unsafe archive entry"
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/release_archive_verification_system_test.rb"
  end
end
