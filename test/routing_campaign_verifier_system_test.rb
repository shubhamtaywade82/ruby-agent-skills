# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingCampaignVerifierSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_rejects_campaign_with_wrong_case_set
    Dir.mktmpdir("routing-campaign-intake") do |dir|
      path = File.join(dir, "campaign.json")
      campaign = {"protocol_version"=>1,"campaign"=>"skill-routing-public-v1","campaign_version"=>1,"routing_case_count"=>14,"requested_repetitions"=>3,"requested_runs"=>42,"completed_runs"=>42,"complete"=>true,"agent"=>{"provider"=>"ollama","model"=>"test-model"},"cases"=>{}}
      File.write(path, JSON.pretty_generate(campaign))
      _stdout, stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "bin", "routing-campaign-verify"), path, chdir: ROOT)
      refute status.success?
      assert_includes stderr, "campaign cases must contain exactly the public routing case IDs"
    end
  end

  def test_rejects_incomplete_campaign
    Dir.mktmpdir("routing-campaign-intake") do |dir|
      path = File.join(dir, "campaign.json")
      campaign = {"protocol_version"=>1,"campaign"=>"skill-routing-public-v1","campaign_version"=>1,"routing_case_count"=>14,"requested_repetitions"=>3,"requested_runs"=>42,"completed_runs"=>41,"complete"=>false,"agent"=>{"provider"=>"ollama","model"=>"test-model"},"cases"=>{}}
      File.write(path, JSON.pretty_generate(campaign))
      _stdout, stderr, status = Open3.capture3(RbConfig.ruby, File.join(ROOT, "bin", "routing-campaign-verify"), path, chdir: ROOT)
      refute status.success?
      assert_includes stderr, "completed_runs must equal requested_runs"
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_campaign_verifier_system_test.rb"
  end
end
