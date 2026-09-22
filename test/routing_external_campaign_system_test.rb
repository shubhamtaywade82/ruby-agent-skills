# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"

class RoutingExternalCampaignSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_handoff_enforces_clean_worktree_and_records_contract
    source = File.read(File.join(ROOT, "bin", "routing-campaign-handoff"), encoding: "UTF-8")
    assert_includes source, "repository worktree is dirty"
    assert_includes source, '"handoff" => "skill-routing-external-run-v1"'
    assert_includes source, '"expected_runs" => expected_runs'
  end

  def test_hidden_benchmark_is_external_only
    path = File.join(ROOT, "router", "ROUTING_HIDDEN_BENCHMARK.yml")
    config = YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
    assert_equal "external-only", config.fetch("source")
    assert_equal "external-only", config.fetch("cases").fetch("gold_labels")
    assert_equal "forbidden", config.fetch("cases").fetch("repository_storage")
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_external_campaign_system_test.rb"
  end

  def test_handoff_contract_document_exists
    assert File.file?(File.join(ROOT, "docs", "ROUTING_EXTERNAL_CAMPAIGN_SCHEMA.md"))
  end
end
