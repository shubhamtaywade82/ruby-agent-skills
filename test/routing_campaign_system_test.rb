# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingCampaignSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_analyzer_reports_primary_confusions_and_instability
    Dir.mktmpdir("routing-analysis") do |dir|
      campaign_path = File.join(dir, "campaign.json")
      report_path = File.join(dir, "report.json")

      campaign = {
        "protocol_version" => 1,
        "campaign" => "skill-routing-public-v1",
        "campaign_version" => 1,
        "complete" => true,
        "agent" => {
          "provider" => "ollama",
          "model" => "test-model"
        },
        "routing_case_count" => 1,
        "requested_repetitions" => 3,
        "completed_runs" => 3,
        "cases" => {
          "case-a" => {
            "expected_primary_skill" => "rails-authorization",
            "requested_repetitions" => 3,
            "runs" => [
              {"status" => "completed", "expected" => {"primary_skill" => "rails-authorization", "secondary_skills" => ["rails-test-engineering"]}, "observed" => {"primary_skill" => "rails-authorization", "secondary_skills" => ["rails-test-engineering"]}},
              {"status" => "completed", "expected" => {"primary_skill" => "rails-authorization", "secondary_skills" => ["rails-test-engineering"]}, "observed" => {"primary_skill" => "rails-authorization", "secondary_skills" => ["rails-test-engineering"]}},
              {"status" => "completed", "expected" => {"primary_skill" => "rails-authorization", "secondary_skills" => ["rails-test-engineering"]}, "observed" => {"primary_skill" => "rails-active-record", "secondary_skills" => ["rails-test-engineering"]}}
            ]
          }
        }
      }

      File.write(campaign_path, JSON.pretty_generate(campaign))

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-analyze"),
        campaign_path,
        "--output", report_path,
        chdir: ROOT
      )

      assert status.success?, "#{stdout}\n#{stderr}"

      report = JSON.parse(File.read(report_path, encoding: "UTF-8"))
      assert_equal 1, report.fetch("summary").fetch("primary_mismatch_count")
      assert_equal 1, report.fetch("summary").fetch("confusion_pair_count")
      assert_equal 1, report.fetch("summary").fetch("unstable_case_count")
      assert_in_delta 2.0 / 3.0, report.fetch("summary").fetch("primary_accuracy"), 0.0001
      assert_in_delta 1.0, report.fetch("summary").fetch("secondary_recall"), 0.0001
      assert_in_delta 0.0, report.fetch("summary").fetch("average_unexpected_secondary_count"), 0.0001
      assert_in_delta 2.0 / 3.0, report.fetch("cases").first.fetch("repetition_stability"), 0.0001
      assert_equal "rails-authorization", report.fetch("cases").first.fetch("modal_primary_skill")
      assert_equal "rails-authorization", report.fetch("primary_confusions").first.fetch("expected_primary_skill")
      assert_equal "rails-active-record", report.fetch("primary_confusions").first.fetch("observed_primary_skill")
    end
  end

  def test_campaign_command_fails_cleanly_when_ollama_is_unavailable
    Dir.mktmpdir("routing-campaign") do |dir|
      _stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-campaign"),
        "--model", "missing-test-model",
        "--url", "http://127.0.0.1:1",
        "--output", dir,
        chdir: ROOT
      )

      refute status.success?
      assert_includes stderr, "Ollama unavailable"
    end
  end

  def test_campaign_command_enforces_intake_verification
    runner = File.read(File.join(ROOT, "bin", "routing-campaign"), encoding: "UTF-8")
    assert_includes runner, "routing-campaign-verify"
    assert_includes runner, "routing campaign intake verification failed"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_campaign_system_test.rb"
  end
end
