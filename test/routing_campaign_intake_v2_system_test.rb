# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingCampaignIntakeV2SystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_preflight_verifier_is_runtime_independent
    source = File.read(File.join(ROOT, "bin", "routing-campaign-preflight-verify"), encoding: "UTF-8")
    refute_includes source, "/api/tags"
    refute_includes source, "/api/version"
    assert_includes source, "Digest::SHA256"
  end

  def test_importer_requires_campaign_and_preflight
    source = File.read(File.join(ROOT, "bin", "routing-campaign-import"), encoding: "UTF-8")
    assert_includes source, "campaign.json"
    assert_includes source, "preflight.json"
    assert_includes source, "routing-campaign-evidence"
    assert_includes source, "routing-archive"
  end

  def test_hidden_contract_remains_external_only
    source = File.read(File.join(ROOT, "router", "ROUTING_HIDDEN_BENCHMARK.yml"), encoding: "UTF-8")
    assert_includes source, "source: external-only"
    assert_includes source, "gold_labels: external-only"
    assert_includes source, "repository_storage: forbidden"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_campaign_intake_v2_system_test.rb"
  end
end
