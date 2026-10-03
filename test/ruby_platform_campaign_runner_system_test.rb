# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RubyPlatformCampaignRunnerSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  FAMILIES = %w[ruby-toolchain ruby-gem-development].freeze

  def campaign_command(family, output)
    [
      RbConfig.ruby, File.join(ROOT, "bin", "benchmark"), "campaign",
      "--manifest", File.join(ROOT, "benchmarks", family, "campaign.yml"),
      "--agent-command", "true", "--runs", "3", "--continue-on-failure",
      "--output", output
    ]
  end

  def campaign_result(family, output)
    path = File.join(output, "campaign.json")
    result = JSON.parse(File.read(path, encoding: "UTF-8"))
    result.dig("evaluations", "#{family}-contract")
  end

  def run_campaign(family)
    Dir.mktmpdir("ruby-platform-campaign") do |output|
      _, _, status = Open3.capture3(*campaign_command(family, output), chdir: ROOT)
      [status.success?, campaign_result(family, output)]
    end
  rescue StandardError
    [false, nil]
  end

  def complete_campaign?(family)
    success, evaluation = run_campaign(family)
    success &&
      evaluation &&
      evaluation["complete"] == true &&
      evaluation["baseline_completed_repetitions"] == 3 &&
      evaluation["skills_completed_repetitions"] == 3
  end

  def test_foundation_campaigns_complete_three_paired_repetitions
    failures = FAMILIES.reject { |family| complete_campaign?(family) }

    assert_empty failures, "foundation benchmark campaign smoke run did not complete"
  end
end
