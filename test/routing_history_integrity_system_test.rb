# frozen_string_literal: true

require "digest"
require "json"
require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingHistoryIntegritySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def source(path)
    File.read(File.join(ROOT, path), encoding: "UTF-8")
  end

  def test_history_has_an_independent_verifier
    script = source("bin/routing-history-verify")
    assert_includes script, "routing-archive-verify"
    assert_includes script, "archive_id"
    assert_includes script, "SHA-256"
  end

  def test_history_generation_can_require_verified_archives
    script = source("bin/routing-history")
    assert_includes script, "--verify"
    assert_includes script, "routing-history-verify"
  end

  def test_matrix_report_can_gate_on_verified_history
    script = source("bin/routing-model-matrix-report")
    assert_includes script, "--verify"
    assert_includes script, "routing-history-verify"
    assert_includes script, "descriptive-only"
  end

  def test_validator_executes_this_system_test
    assert_includes source("bin/validate"), "test/routing_history_integrity_system_test.rb"
  end

  def test_history_verifier_rejects_tampered_archive
    Dir.mktmpdir("routing-history-integrity") do |dir|
      archive = build_archive(dir)
      history = {
        "protocol_version" => 1,
        "history" => "skill-routing-history-v1",
        "archive_root" => dir,
        "campaign_count" => 1,
        "entries" => [{
          "archive_id" => "skill-routing-public-v1/fixture-model/abc123",
          "captured_at" => "2026-09-23T00:00:00Z",
          "captured_at" => "2026-09-23T00:00:00Z",
          "campaign" => "skill-routing-public-v1",
          "evidence_type" => "skill-routing-campaign-v1",
          "repository" => {"git_sha" => "abc123", "worktree_clean" => true},
          "agent" => {"provider" => "ollama", "model" => "fixture-model"},
          "campaign_metrics" => {"primary_accuracy" => 1.0, "secondary_recall" => 1.0, "average_unexpected_secondary_count" => 0.0},
          "analysis" => {"primary_accuracy" => 1.0},
          "artifact_count" => 1,
          "archive_path" => archive
        }]
      }
      history_path = File.join(dir, "history.json")
      File.write(history_path, JSON.pretty_generate(history), encoding: "UTF-8")

      verifier = File.join(ROOT, "bin", "routing-history-verify")
      _stdout, stderr, status = Open3.capture3(RbConfig.ruby, verifier, history_path, "--check-files", chdir: ROOT)
      assert status.success?, stderr

      File.write(File.join(archive, "artifacts", "raw-result.json"), "tampered", encoding: "UTF-8")
      _stdout, mismatch_stderr, mismatch_status = Open3.capture3(
        RbConfig.ruby, verifier, history_path, "--check-files", chdir: ROOT
      )
      refute mismatch_status.success?
      assert_includes mismatch_stderr, "archive verification failed"
    end
  end

  private

  def build_archive(root)
    archive = File.join(root, "skill-routing-public-v1", "fixture-model", "abc123")
    artifacts = File.join(archive, "artifacts")
    FileUtils.mkdir_p(artifacts)

    artifact_path = File.join(artifacts, "raw-result.json")
    File.write(artifact_path, "{}
", encoding: "UTF-8")
    artifact_sha = Digest::SHA256.file(artifact_path).hexdigest

    evidence = {
      "protocol_version" => 1,
      "evidence" => "skill-routing-campaign-v1",
      "campaign" => "skill-routing-public-v1",
      "repository" => {"git_sha" => "abc123", "worktree_clean" => true},
      "agent" => {"provider" => "ollama", "model" => "fixture-model"},
      "campaign_metrics" => {"primary_accuracy" => 1.0, "secondary_recall" => 1.0, "average_unexpected_secondary_count" => 0.0},
      "requested_runs" => 1,
      "completed_runs" => 1,
      "analysis" => {"primary_accuracy" => 1.0},
      "artifacts" => {
        "raw_result" => {"path" => "/source/raw-result.json", "sha256" => artifact_sha, "bytes" => File.size(artifact_path)}
      }
    }
    evidence_path = File.join(archive, "evidence.json")
    File.write(evidence_path, JSON.pretty_generate(evidence), encoding: "UTF-8")

    manifest = {
      "protocol_version" => 1,
      "archive" => "skill-routing-evidence-archive-v1",
      "archive_id" => "skill-routing-public-v1/fixture-model/abc123",
      "captured_at" => "2026-09-23T00:00:00Z",
      "source_evidence" => {
        "path" => "/source/evidence.json",
        "sha256" => Digest::SHA256.file(evidence_path).hexdigest,
        "archive_path" => "evidence.json"
      },
      "repository" => evidence["repository"],
      "agent" => evidence["agent"],
      "evidence_type" => evidence["evidence"],
      "campaign_metrics" => evidence["campaign_metrics"],
      "requested_runs" => 1,
      "completed_runs" => 1,
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
    File.write(File.join(archive, "ARCHIVE_MANIFEST.json"), JSON.pretty_generate(manifest), encoding: "UTF-8")
    archive
  end
end
