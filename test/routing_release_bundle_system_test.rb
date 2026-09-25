# frozen_string_literal: true

require "digest"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingReleaseBundleSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def source(path)
    File.read(File.join(ROOT, path), encoding: "UTF-8")
  end

  def test_release_scripts_parse_as_ruby
    %w[
      bin/routing-hidden-benchmark-receipt-verify
      bin/routing-release-bundle
      bin/routing-release-bundle-verify
    ].each do |path|
      _stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-c", File.join(ROOT, path), chdir: ROOT)
      assert status.success?, "#{path}: #{stderr}"
    end
  end

  def test_hidden_receipt_has_standalone_verifier
    script = source("bin/routing-hidden-benchmark-receipt-verify")
    assert_includes script, "external-only"
    assert_includes script, "gold_labels"
    assert_includes script, "artifact"
  end

  def test_hidden_receipt_verifier_accepts_intact_receipt_and_rejects_tamper
    Dir.mktmpdir("hidden-receipt") do |dir|
      artifact = File.join(dir, "artifact.json")
      File.write(artifact, '{"runs":1}', encoding: "UTF-8")
      receipt = {
        "protocol_version" => 1,
        "receipt" => "skill-routing-hidden-benchmark-intake-v1",
        "benchmark" => "skill-routing-hidden-v1",
        "verification" => {
          "passed" => true,
          "source" => "external-only",
          "repository_storage" => "forbidden",
          "gold_labels_in_repository" => false,
          "hidden_cases_in_repository" => false
        },
        "external_execution" => {
          "case_count" => 1,
          "repetitions" => 1,
          "completed_runs" => 1,
          "provider" => "ollama",
          "model" => "external-model"
        },
        "artifact" => {
          "path" => artifact,
          "sha256" => Digest::SHA256.file(artifact).hexdigest,
          "bytes" => File.size(artifact)
        }
      }
      receipt_path = File.join(dir, "receipt.json")
      File.write(receipt_path, JSON.pretty_generate(receipt), encoding: "UTF-8")
      verifier = File.join(ROOT, "bin", "routing-hidden-benchmark-receipt-verify")

      _stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, verifier, receipt_path, "--check-files", chdir: ROOT
      )
      assert status.success?, stderr

      File.write(artifact, '{"runs":2}', encoding: "UTF-8")
      _stdout, mismatch_stderr, mismatch_status = Open3.capture3(
        RbConfig.ruby, verifier, receipt_path, "--check-files", chdir: ROOT
      )
      refute mismatch_status.success?
      assert_includes mismatch_stderr, "artifact SHA-256 mismatch"
    end
  end

  def test_release_bundle_requires_public_evidence
    script = source("bin/routing-release-bundle")
    assert_includes script, "--public-evidence"
    assert_includes script, "routing-release-check"
    assert_includes script, "routing-campaign-evidence-verify"
  end

  def test_release_bundle_can_include_matrix_and_hidden_receipt
    script = source("bin/routing-release-bundle")
    assert_includes script, "--matrix-evidence"
    assert_includes script, "--hidden-receipt"
    assert_includes script, "routing-model-matrix-evidence-verify"
    assert_includes script, "routing-hidden-benchmark-receipt-verify"
  end

  def test_release_bundle_self_verifies_after_creation
    script = source("bin/routing-release-bundle")
    assert_includes script, "routing-release-bundle-verify"
    assert_includes script, "RELEASE_MANIFEST.json"
  end

  def test_release_check_accepts_a_finished_bundle
    script = source("bin/routing-release-check")
    assert_includes script, "--bundle"
    assert_includes script, "routing-release-bundle-verify"
  end

  def test_release_bundle_verifier_requires_public_component
    script = source("bin/routing-release-bundle-verify")
    assert_includes script, "public release component is required"
  end

  def test_release_bundle_verifier_rechecks_every_component
    script = source("bin/routing-release-bundle-verify")
    assert_includes script, "public campaign evidence verification failed"
    assert_includes script, "routing-model-matrix-evidence-verify"
    assert_includes script, "routing-hidden-benchmark-receipt-verify"
    assert_includes script, "SHA-256 mismatch"
  end

  def test_release_bundle_preserves_external_hidden_boundary
    script = source("bin/routing-release-bundle-verify")
    assert_includes script, 'verification["source"] == "external-only"'
    assert_includes script, "gold_labels"
    assert_includes script, "hidden_cases"
  end

  def test_validator_executes_this_system_test
    assert_includes source("bin/validate"), "test/routing_release_bundle_system_test.rb"
  end
end
