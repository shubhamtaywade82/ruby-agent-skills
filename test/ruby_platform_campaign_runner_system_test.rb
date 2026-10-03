# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RubyPlatformCampaignRunnerSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  FAMILIES = %w[ruby-toolchain ruby-gem-development].freeze

  def run_campaign(family)
    Dir.mktmpdir("ruby-platform-campaign") do |output|
      _, _, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "benchmark"),
        "campaign",
        "--manifest",
        File.join(ROOT, "benchmarks", family, "campaign.yml"),
        "--agent-command",
        "true",
        "--runs",
        "3",
        "--continue-on-failure",
        "--output",
        output,
        chdir: ROOT
      )
      result_path = File.join(output, "campaign.json")
      result = JSON.parse(File.read(result_path, encoding: "UTF-8"))
      [status.success?, result]
    end
  rescue StandardError
    [false, {}]
  end

  def test_foundation_campaigns_complete_three_paired_repetitions
    failures = FAMILIES.each_with_object([]) do |family, failures|
      success, result = run_campaign(family)
      evaluation = result.dig("evaluations", "#{family}-contract")
      complete = result.dig("measurement", "complete") == true
      repetitions = evaluation && [
        evaluation["baseline_completed_repetitions"],
        evaluation["skills_completed_repetitions"]
      ] == [3, 3]
      failures << family unless success && complete && repetitions
    end

    assert_empty failures, "foundation benchmark campaign smoke run did not complete"
  end
end
