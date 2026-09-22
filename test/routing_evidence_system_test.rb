# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingEvidenceSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_evidence_pack_hashes_experiment_and_contract_artifacts
    Dir.mktmpdir("routing-evidence") do |dir|
      router = File.join(dir, "ROUTING.md")
      File.write(router, "# Test routing contract\n")

      baseline = {
        "protocol_version" => 1,
        "campaign" => "skill-routing-public-v1",
        "campaign_version" => 1,
        "routing_case_count" => 1,
        "requested_repetitions" => 1,
        "complete" => true,
        "routing_contract" => router,
        "agent" => {"provider" => "test", "model" => "test-model", "model_version" => nil, "tool_mode" => "test"},
        "metrics" => {"primary_accuracy" => 1.0, "secondary_recall" => 1.0, "average_unexpected_secondary_count" => 0.0}
      }
      candidate = baseline.dup
      comparison = {"deltas" => {"primary_accuracy" => 0.0, "secondary_recall" => 0.0, "average_unexpected_secondary_count" => 0.0}, "gate" => {"passed" => true, "errors" => []}}

      File.write(File.join(dir, "baseline.json"), JSON.pretty_generate(baseline))
      File.write(File.join(dir, "candidate.json"), JSON.pretty_generate(candidate))
      File.write(File.join(dir, "comparison.json"), JSON.pretty_generate(comparison))

      output = File.join(dir, "evidence.json")
      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-evidence"),
        dir,
        "--output", output,
        chdir: ROOT
      )

      assert status.success?, "#{stdout}\n#{stderr}"
      evidence = JSON.parse(File.read(output, encoding: "UTF-8"))

      assert_equal true, evidence.fetch("compatibility").fetch("same_agent_configuration")
      assert_equal true, evidence.fetch("compatibility").fetch("same_campaign")
      assert_equal true, evidence.fetch("compatibility").fetch("same_campaign_version")
      assert_equal true, evidence.fetch("compatibility").fetch("same_routing_case_count")
      assert_equal true, evidence.fetch("compatibility").fetch("same_repetition_count")
      assert_equal true, evidence.fetch("gate").fetch("passed")
      assert_equal 64, evidence.fetch("artifacts").fetch("baseline").fetch("sha256").length
      assert_equal 64, evidence.fetch("artifacts").fetch("baseline_routing_contract").fetch("sha256").length
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_evidence_system_test.rb"
  end
end
