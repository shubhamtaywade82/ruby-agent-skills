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

  def test_hidden_receipt_has_standalone_verifier
    script = source("bin/routing-hidden-benchmark-receipt-verify")
    assert_includes script, "external-only"
    assert_includes script, "gold_labels"
    assert_includes script, "artifact"
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
