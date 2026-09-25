# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingArchiveIntegritySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  VERIFYER = File.join(ROOT, "bin", "routing-archive-verify")

  def run_verifier(archive_dir)
    Open3.capture3(RbConfig.ruby, VERIFYER, archive_dir, chdir: ROOT)
  end

  def test_verifier_accepts_intact_campaign_archive
    Dir.mktmpdir("routing-archive") do |dir|
      archive = build_archive(dir)
      stdout, stderr, status = run_verifier(archive)

      assert status.success?, "#{stdout}\n#{stderr}"
      assert_includes stdout, "Routing evidence archive verification passed."
    end
  end

  def test_verifier_rejects_tampered_archived_artifact
    Dir.mktmpdir("routing-archive") do |dir|
      archive = build_archive(dir)
      artifact = File.join(archive, "artifacts", "raw-result.json")
      File.write(artifact, "tampered", encoding: "UTF-8")

      _stdout, stderr, status = run_verifier(archive)

      refute status.success?
      assert_includes stderr, "artifact raw_result SHA-256 mismatch"
    end
  end

  def test_verifier_rejects_manifest_artifact_path_escape
    Dir.mktmpdir("routing-archive") do |dir|
      archive = build_archive(dir)
      manifest_path = File.join(archive, "ARCHIVE_MANIFEST.json")
      manifest = JSON.parse(File.read(manifest_path, encoding: "UTF-8"))
      manifest.fetch("artifacts").fetch("raw_result")["archive_path"] = "../outside.json"
      File.write(manifest_path, JSON.pretty_generate(manifest) + "\n", encoding: "UTF-8")

      _stdout, stderr, status = run_verifier(archive)

      refute status.success?
      assert_includes stderr, "archive path must be relative and stay within archive"
    end
  end

  def test_verifier_rejects_tampered_evidence
    Dir.mktmpdir("routing-archive") do |dir|
      archive = build_archive(dir)
      evidence_path = File.join(archive, "evidence.json")
      evidence = JSON.parse(File.read(evidence_path, encoding: "UTF-8"))
      evidence["analysis"]["primary_accuracy"] = 0.0
      File.write(evidence_path, JSON.pretty_generate(evidence) + "\n", encoding: "UTF-8")

      _stdout, stderr, status = run_verifier(archive)

      refute status.success?
      assert_includes stderr, "source evidence SHA-256 mismatch"
    end
  end

  def test_archive_writer_self_verifies_and_release_gate_verifies_supplied_archive
    archive_source = File.read(File.join(ROOT, "bin", "routing-archive"), encoding: "UTF-8")
    release_source = File.read(File.join(ROOT, "bin", "routing-release-check"), encoding: "UTF-8")

    assert_includes archive_source, "routing-archive-verify"
    assert_includes release_source, "ARCHIVE_VERIFIER"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_archive_integrity_system_test.rb"
  end

  private

  def build_archive(root)
    archive = File.join(root, "skill-routing-public-v1", "fixture-model", "abc123")
    artifact_dir = File.join(archive, "artifacts")
    FileUtils.mkdir_p(artifact_dir)

    artifact_path = File.join(artifact_dir, "raw-result.json")
    File.write(artifact_path, "{}\n", encoding: "UTF-8")

    evidence = {
      "protocol_version" => 1,
      "evidence" => "skill-routing-campaign-v1",
      "campaign" => "skill-routing-public-v1",
      "campaign_version" => 1,
      "repository" => {"git_sha" => "abc123", "worktree_clean" => true},
      "agent" => {"provider" => "ollama", "model" => "fixture-model"},
      "campaign_metrics" => {
        "primary_accuracy" => 1.0,
        "secondary_recall" => 1.0,
        "average_unexpected_secondary_count" => 0.0
      },
      "analysis" => {"primary_accuracy" => 1.0},
      "requested_runs" => 1,
      "completed_runs" => 1,
      "artifacts" => {
        "raw_result" => {
          "path" => "/source/raw-result.json",
          "sha256" => Digest::SHA256.file(artifact_path).hexdigest,
          "bytes" => File.size(artifact_path)
        }
      }
    }

    evidence_path = File.join(archive, "evidence.json")
    File.write(evidence_path, JSON.pretty_generate(evidence) + "\n", encoding: "UTF-8")

    evidence_sha = Digest::SHA256.file(evidence_path).hexdigest
    artifact_sha = Digest::SHA256.file(artifact_path).hexdigest
    manifest = {
      "protocol_version" => 1,
      "archive" => "skill-routing-evidence-archive-v1",
      "archive_id" => "skill-routing-public-v1/fixture-model/abc123",
      "source_evidence" => {
        "path" => "/source/evidence.json",
        "sha256" => evidence_sha,
        "archive_path" => "evidence.json"
      },
      "repository" => evidence["repository"],
      "agent" => evidence["agent"],
      "evidence_type" => evidence["evidence"],
      "campaign_metrics" => evidence["campaign_metrics"],
      "requested_runs" => evidence["requested_runs"],
      "completed_runs" => evidence["completed_runs"],
      "analysis" => evidence["analysis"],
      "artifacts" => {
        "raw_result" => {
          "source_path" => "/source/raw-result.json",
          "archive_path" => "artifacts/raw-result.json",
          "sha256" => artifact_sha,
          "bytes" => File.size(artifact_path)
        }
      }
    }
    File.write(
      File.join(archive, "ARCHIVE_MANIFEST.json"),
      JSON.pretty_generate(manifest) + "\n",
      encoding: "UTF-8"
    )

    archive
  end
end
