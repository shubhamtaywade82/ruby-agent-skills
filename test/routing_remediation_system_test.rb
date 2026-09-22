# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tempfile"

class RoutingRemediationSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def write_campaign(path, primary_skill:, candidate: false, accuracy: 1.0)
    observed = candidate ? "rails-active-record" : primary_skill
    campaign = {
      "protocol_version" => 1,
      "campaign" => "skill-routing-public-v1",
      "campaign_version" => 1,
      "complete" => true,
      "agent" => {"provider" => "test", "model" => "test-model"},
      "metrics" => {
        "primary_accuracy" => accuracy,
        "secondary_recall" => 1.0,
        "average_unexpected_secondary_count" => 0.0
      },
      "cases" => {
        "case-a" => {
          "expected_primary_skill" => primary_skill,
          "runs" => 3.times.map {
            {
              "status" => "completed",
              "expected" => {"primary_skill" => primary_skill},
              "observed" => {"primary_skill" => observed}
            }
          }
        }
      }
    }
    File.write(path, JSON.pretty_generate(campaign))
  end

  def test_comparison_detects_resolved_confusion
    Dir.mktmpdir("routing-remediation") do |dir|
      baseline = File.join(dir, "baseline.json")
      candidate = File.join(dir, "candidate.json")
      report = File.join(dir, "report.json")

      write_campaign(baseline, primary_skill: "rails-authorization", candidate: true, accuracy: 0.0)
      write_campaign(candidate, primary_skill: "rails-authorization", candidate: false, accuracy: 1.0)

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-compare"),
        baseline,
        candidate,
        "--output", report,
        chdir: ROOT
      )

      assert status.success?, "#{stdout}\n#{stderr}"
      result = JSON.parse(File.read(report, encoding: "UTF-8"))
      assert_equal true, result.fetch("gate").fetch("passed")
      assert_includes result.fetch("confusions").fetch("resolved"), ["rails-authorization", "rails-active-record"]
      assert_empty result.fetch("confusions").fetch("new")
      assert_equal 1.0, result.fetch("deltas").fetch("primary_accuracy")
    end
  end

  def test_comparison_rejects_new_confusion_pair
    Dir.mktmpdir("routing-remediation") do |dir|
      baseline = File.join(dir, "baseline.json")
      candidate = File.join(dir, "candidate.json")

      write_campaign(baseline, primary_skill: "rails-authorization", candidate: false, accuracy: 1.0)
      write_campaign(candidate, primary_skill: "rails-authorization", candidate: true, accuracy: 0.0)

      _stdout, _stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-compare"),
        baseline,
        candidate,
        chdir: ROOT
      )

      refute status.success?
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_remediation_system_test.rb"
  end
end
