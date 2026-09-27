# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class ReleaseArchiveVerificationSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  BUILDER = File.join(ROOT, "scripts", "build_release_archive.rb")
  VERIFIER = File.join(ROOT, "scripts", "verify_release_archive.rb")

  def build(root, version = "v0.0.1")
    Open3.capture3(
      RbConfig.ruby, BUILDER,
      "--version", version,
      "--output", File.join(root, "dist"),
      chdir: ROOT
    )
  end

  def test_verifier_accepts_archive_and_published_checksum
    Dir.mktmpdir("release-verify") do |dir|
      _out, err, status = build(dir)
      assert status.success?, err

      archive = File.join(dir, "dist", "ruby-agent-skills-v0.0.1.tar.gz")
      sums = File.join(dir, "dist", "SHA256SUMS")

      stdout, stderr, verify_status = Open3.capture3(
        RbConfig.ruby, VERIFIER, archive, "--checksums", sums, chdir: ROOT
      )

      assert verify_status.success?, "#{stdout}\n#{stderr}"
      assert_includes stdout, "Release archive verification passed."
      assert_includes stdout, "RELEASE.json"
    end
  end

  def test_verifier_rejects_tampered_archive
    Dir.mktmpdir("release-verify-tamper") do |dir|
      _out, err, status = build(dir)
      assert status.success?, err

      archive = File.join(dir, "dist", "ruby-agent-skills-v0.0.1.tar.gz")
      File.open(archive, "ab") { |file| file.write("tampered") }

      _stdout, stderr, verify_status = Open3.capture3(
        RbConfig.ruby, VERIFIER, archive, chdir: ROOT
      )

      refute verify_status.success?
      assert_includes stderr, "archive SHA-256 mismatch"
    end
  end

  def test_verifier_rejects_provenance_inventory_drift
    Dir.mktmpdir("release-verify-provenance") do |dir|
      _out, err, status = build(dir)
      assert status.success?, err

      archive = File.join(dir, "dist", "ruby-agent-skills-v0.0.1.tar.gz")
      extract = File.join(dir, "extract")
      Dir.mkdir(extract)
      system("tar", "-xzf", archive, "-C", extract, exception: true)

      release = Dir[File.join(extract, "**", "RELEASE.json")].fetch(0)
      data = JSON.parse(File.read(release, encoding: "UTF-8"))
      data["skills"] = data.fetch("skills") + 1
      File.write(release, JSON.pretty_generate(data) + "\n", encoding: "UTF-8")

      tampered = File.join(dir, "tampered.tar.gz")
      system("tar", "-czf", tampered, "-C", extract, File.basename(Dir[File.join(extract, "*")].fetch(0)), exception: true)

      _stdout, stderr, verify_status = Open3.capture3(
        RbConfig.ruby, VERIFIER, tampered, chdir: ROOT
      )

      refute verify_status.success?
      assert_includes stderr, "skill inventory mismatch"
    end
  end

  def test_validator_registers_release_archive_verification
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/release_archive_verification_system_test.rb"
  end
end
