# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RoutingReleaseReadinessSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_release_contract_requires_42_completed_runs
    config = YAML.safe_load(File.read(File.join(ROOT, "router", "ROUTING_RELEASE.yml"), encoding: "UTF-8"), permitted_classes: [], aliases: false)
    assert_equal 14, config.fetch("campaign").fetch("expected_case_count")
    assert_equal 3, config.fetch("campaign").fetch("expected_repetitions")
    assert_equal 42, config.fetch("campaign").fetch("expected_runs")
    assert_equal true, config.fetch("gates").fetch("public_campaign_evidence_required")
  end

  def test_release_policy_forbids_synthetic_and_unverified_results
    config = YAML.safe_load(File.read(File.join(ROOT, "router", "ROUTING_RELEASE.yml"), encoding: "UTF-8"), permitted_classes: [], aliases: false)
    assert_equal true, config.fetch("controls").fetch("no_synthetic_results")
    assert_equal true, config.fetch("controls").fetch("no_unverified_results")
  end

  def test_release_check_is_explicitly_evidence_driven
    source = File.read(File.join(ROOT, "bin", "routing-release-check"), encoding: "UTF-8")
    assert_includes source, "routing-campaign-evidence-verify"
    assert_includes source, "expected_runs"
    assert_includes source, "routing-campaign-evidence-verify"
  end

  def test_validator_executes_this_system_test
    source = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes source, "test/routing_release_readiness_system_test.rb"
  end
end
