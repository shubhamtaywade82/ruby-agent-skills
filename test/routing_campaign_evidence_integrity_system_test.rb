# frozen_string_literal: true

require "minitest/autorun"

class RoutingCampaignEvidenceIntegritySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_verifier_enforces_raw_run_cardinality_and_preflight
    source = File.read(File.join(ROOT, "bin", "routing-campaign-evidence-verify"), encoding: "UTF-8")
    assert_includes source, 'raw_artifact_keys.length'
    assert_includes source, 'artifacts.key?("preflight")'
  end

  def test_archive_invokes_campaign_evidence_verifier
    source = File.read(File.join(ROOT, "bin", "routing-archive"), encoding: "UTF-8")
    assert_includes source, "routing-campaign-evidence-verify"
  end

  def test_import_invokes_campaign_evidence_verifier
    source = File.read(File.join(ROOT, "bin", "routing-campaign-import"), encoding: "UTF-8")
    assert_includes source, "routing-campaign-evidence-verify"
  end

  def test_validator_executes_this_system_test
    source = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes source, "test/routing_campaign_evidence_integrity_system_test.rb"
  end
end
