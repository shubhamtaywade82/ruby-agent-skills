# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingModelMatrixEvidenceSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  PACKAGER = File.join(ROOT, "bin", "routing-model-matrix-evidence")
  VERIFIER = File.join(ROOT, "bin", "routing-model-matrix-evidence-verify")
  RUNNER = File.join(ROOT, "bin", "routing-model-matrix-campaign")

  def write_plan(dir)
    plan_path = File.join(dir, "matrix-plan.json")
    evidence = File.join(dir, "model-a-evidence.json")
    archive = File.join(dir, "model-a-archive")
    FileUtils.mkdir_p(archive)

    File.write(evidence, '{"evidence":"fixture"}\n', encoding: "UTF-8")
    File.write(File.join(archive, "ARCHIVE.json"), '{"archive":"fixture"}\n', encoding: "UTF-8")

    plan = {
      "protocol_version" => 1,
      "execution" => "skill-routing-model-matrix-campaign-v1",
      "mode" => "execute",
      "campaign" => {"id" => "skill-routing-public-v1", "version" => 1, "repetitions" => 1, "expected_runs_per_model" => 1},
      "provenance" => {"git_sha" => "a" * 40, "matrix_sha256" => "b" * 64, "campaign_sha256" => "c" * 64, "routing_cases_sha256" => "d" * 64},
      "runtime" => {"provider" => "ollama", "url" => "http://127.0.0.1:11434", "timeout_seconds" => 300},
      "models" => [{"provider" => "ollama", "name" => "model-a", "status" => "completed_and_archived"}],
      "controls" => {"descriptive_comparison_only" => true, "no_synthetic_results" => true},
      "results" => [{
        "provider" => "ollama",
        "model" => "model-a",
        "status" => "completed_and_archived",
        "evidence" => evidence,
        "archive" => archive
      }]
    }
    File.write(plan_path, JSON.pretty_generate(plan) + "\n", encoding: "UTF-8")
    [plan_path, evidence, archive]
  end

  def test_packager_creates_matrix_evidence_manifest
    Dir.mktmpdir("routing-matrix-evidence") do |dir|
      plan, evidence, archive = write_plan(dir)
      output = File.join(dir, "matrix-evidence.json")

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, PACKAGER, plan, "--output", output, chdir: ROOT
      )
      assert status.success?, "#{stdout}\n#{stderr}"

      aggregate = JSON.parse(File.read(output, encoding: "UTF-8"))
      assert_equal "skill-routing-model-matrix-evidence-v1", aggregate.fetch("execution")
      assert_equal 1, aggregate.fetch("model_count")
      entry = aggregate.fetch("models").fetch(0)
      assert_equal "model-a", entry.fetch("model")
      assert_equal Digest::SHA256.file(evidence).hexdigest, entry.fetch("evidence").fetch("sha256")
      assert_equal Digest::SHA256.file(File.join(archive, "ARCHIVE.json")).hexdigest,
        entry.fetch("archive").fetch("artifacts").fetch("ARCHIVE.json")
    end
  end

  def test_packager_rejects_incomplete_matrix
    Dir.mktmpdir("routing-matrix-evidence") do |dir|
      plan, = write_plan(dir)
      data = JSON.parse(File.read(plan, encoding: "UTF-8"))
      data["results"][0]["status"] = "failed"
      File.write(plan, JSON.pretty_generate(data) + "\n", encoding: "UTF-8")

      _stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, PACKAGER, plan, chdir: ROOT
      )
      refute status.success?
      assert_includes stderr, "all matrix models must be completed_and_archived"
    end
  end

  def test_verifier_rejects_tampered_matrix_plan
    Dir.mktmpdir("routing-matrix-evidence") do |dir|
      plan, = write_plan(dir)
      output = File.join(dir, "matrix-evidence.json")
      _stdout, stderr, status = Open3.capture3(RbConfig.ruby, PACKAGER, plan, "--output", output, chdir: ROOT)
      assert status.success?, stderr

      data = JSON.parse(File.read(plan, encoding: "UTF-8"))
      data["runtime"]["timeout_seconds"] = 301
      File.write(plan, JSON.pretty_generate(data) + "\n", encoding: "UTF-8")

      _stdout, mismatch_stderr, mismatch_status = Open3.capture3(
        RbConfig.ruby, VERIFIER, output, "--check-files", chdir: ROOT
      )
      refute mismatch_status.success?
      assert_includes mismatch_stderr, "matrix plan SHA-256 mismatch"
    end
  end

  def test_matrix_runner_finalizes_aggregate_evidence
    source = File.read(RUNNER, encoding: "UTF-8")
    assert_includes source, "routing-model-matrix-evidence"
    assert_includes source, "matrix-evidence.json"
    assert_includes source, "routing-model-matrix-evidence-verify"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_model_matrix_evidence_system_test.rb"
  end
end
