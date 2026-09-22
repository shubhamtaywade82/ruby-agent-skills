# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingCampaignPreflightSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_preflight_fails_cleanly_when_ollama_is_unavailable
    Dir.mktmpdir("routing-preflight") do |dir|
      _stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-campaign-preflight"),
        "--model", "missing-test-model",
        "--url", "http://127.0.0.1:1",
        "--output", File.join(dir, "preflight.json"),
        chdir: ROOT
      )
      refute status.success?
      assert_includes stderr, "Ollama unavailable"
    end
  end

  def test_campaign_runner_requires_preflight_before_evaluation
    runner = File.read(File.join(ROOT, "bin", "routing-campaign"), encoding: "UTF-8")
    preflight_index = runner.index("PREFLIGHT")
    evaluator_index = runner.index("EVALUATOR")
    refute_nil preflight_index
    refute_nil evaluator_index
    assert_operator preflight_index, :<, evaluator_index
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_campaign_preflight_system_test.rb"
  end
end
