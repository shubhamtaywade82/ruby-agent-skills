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
        "completed_runs" => 3,
        "cases" => {
          "case-a" => {
            "expected_primary_skill" => "rails-authorization",
            "requested_repetitions" => 3,
            "runs" => [
              {"status" => "completed", "observed" => {"primary_skill" => "rails-authorization"}},
              {"status" => "completed", "observed" => {"primary_skill" => "rails-authorization"}},
              {"status" => "completed", "observed" => {"primary_skill" => "rails-active-record"}}
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

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_campaign_system_test.rb"
  end
end
