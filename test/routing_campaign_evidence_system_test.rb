# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingCampaignEvidenceSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_packager_rejects_invalid_campaign_before_collecting_artifacts
    Dir.mktmpdir("routing-campaign-evidence") do |dir|
      File.write(File.join(dir, "campaign.json"), JSON.pretty_generate({"protocol_version"=>1}))
      File.write(File.join(dir, "routing-report.json"), JSON.pretty_generate({"summary"=>{}}))

      _stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-campaign-evidence"),
        dir,
        chdir: ROOT
      )

      refute status.success?
      assert_includes stderr, "campaign intake verification failed"
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_campaign_evidence_system_test.rb"
  end
end
