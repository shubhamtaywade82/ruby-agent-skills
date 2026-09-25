# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingComparisonProvenanceSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def write_campaign(path, primary_skill:, observed_skill:)
    campaign = {
      "protocol_version" => 1,
      "campaign" => "skill-routing-public-v1",
      "campaign_version" => 1,
      "routing_case_count" => 1,
      "requested_repetitions" => 1,
      "complete" => true,
      "routing_contract" => File.join(File.dirname(path), "#{File.basename(path, ".json")}-router.md"),
      "agent" => {"provider" => "test", "model" => "test-model", "model_version" => nil, "tool_mode" => "test"},
      "metrics" => {
        "primary_accuracy" => observed_skill == primary_skill ? 1.0 : 0.0,
        "secondary_recall" => 1.0,
        "average_unexpected_secondary_count" => 0.0
      },
      "cases" => {
        "case-a" => {
          "expected_primary_skill" => primary_skill,
          "runs" => [{
            "status" => "completed",
            "expected" => {"primary_skill" => primary_skill, "secondary_skills" => []},
            "observed" => {"primary_skill" => observed_skill, "secondary_skills" => []}
          }]
        }
      }
    }
    File.write(path, JSON.pretty_generate(campaign) + "\n", encoding: "UTF-8")
    File.write(campaign.fetch("routing_contract"), "# routing contract\n", encoding: "UTF-8")
  end

  def compare(dir)
    baseline = File.join(dir, "baseline.json")
    candidate = File.join(dir, "candidate.json")
    report = File.join(dir, "comparison.json")
    write_campaign(baseline, primary_skill: "rails-authorization", observed_skill: "rails-authorization")
    write_campaign(candidate, primary_skill: "rails-authorization", observed_skill: "rails-authorization")

    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "bin", "routing-compare"),
      baseline,
      candidate,
      "--output", report,
      chdir: ROOT
    )
    assert status.success?, "#{stdout}\n#{stderr}"
    report
  end

  def test_comparison_records_exact_input_hashes_and_policy_provenance
    Dir.mktmpdir("routing-comparison-provenance") do |dir|
      report_path = compare(dir)
      report = JSON.parse(File.read(report_path, encoding: "UTF-8"))
      provenance = report.fetch("provenance")

      assert_equal File.expand_path(File.join(dir, "baseline.json")), provenance.fetch("baseline").fetch("path")
      assert_equal File.expand_path(File.join(dir, "candidate.json")), provenance.fetch("candidate").fetch("path")
      assert_match(/\A[0-9a-f]{64}\z/, provenance.fetch("baseline").fetch("sha256"))
      assert_match(/\A[0-9a-f]{64}\z/, provenance.fetch("candidate").fetch("sha256"))
      assert_match(/\A[0-9a-f]{64}\z/, provenance.fetch("remediation_policy").fetch("sha256"))
      assert_match(/\A[0-9a-f]{64}\z/, provenance.fetch("comparator").fetch("sha256"))
    end
  end

  def test_comparison_verifier_replays_and_rejects_tampering
    Dir.mktmpdir("routing-comparison-verify") do |dir|
      report_path = compare(dir)
      verifier = File.join(ROOT, "bin", "routing-compare-verify")

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, verifier, report_path, "--check-files", chdir: ROOT
      )
      assert status.success?, "#{stdout}\n#{stderr}"

      report = JSON.parse(File.read(report_path, encoding: "UTF-8"))
      report["deltas"]["primary_accuracy"] = 123.0
      File.write(report_path, JSON.pretty_generate(report) + "\n", encoding: "UTF-8")

      _stdout, mismatch_stderr, mismatch_status = Open3.capture3(
        RbConfig.ruby, verifier, report_path, "--check-files", chdir: ROOT
      )
      refute mismatch_status.success?
      assert_includes mismatch_stderr, "does not match recomputed comparison"
    end
  end

  def test_experiment_finalizes_and_verifies_routing_evidence
    script = File.read(File.join(ROOT, "bin", "routing-experiment"), encoding: "UTF-8")
    assert_includes script, "routing-evidence"
    assert_includes script, "routing-evidence-verify"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_comparison_provenance_system_test.rb"
  end
end
