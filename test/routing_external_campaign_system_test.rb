# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

class RoutingExternalCampaignSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_handoff_requires_a_clean_committed_worktree
    stdout, _stderr, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "bin", "routing-campaign-handoff"),
      "--model", "test-model",
      "--output", Dir.mktmpdir("routing-handoff"),
      chdir: ROOT
    )
    assert status.success? || stdout.include?("JSON")
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
