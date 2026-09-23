# frozen_string_literal: true

require "digest"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingCampaignHandoffBindingSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  RUNNER = File.join(ROOT, "bin", "routing-campaign-handoff-verify")

  def valid_handoff(root)
    sha = Open3.capture2("git", "-C", root, "rev-parse", "HEAD").first.strip
    {
      "protocol_version" => 1,
      "handoff" => "skill-routing-external-run-v1",
      "campaign" => {
        "id" => "skill-routing-public-v1",
        "version" => 1,
        "case_count" => 14,
        "repetitions" => 3,
        "expected_runs" => 42
      },
      "runtime" => {
        "provider" => "ollama",
        "url" => "http://127.0.0.1:11434",
        "model" => "test-model"
      },
      "repository" => {
        "git_sha" => sha,
        "worktree_clean" => true
      },
      "artifacts" => {
        "skill_manifest_sha256" => Digest::SHA256.file(File.join(root, "skill-manifest.yml")).hexdigest,
        "campaign_manifest_sha256" => Digest::SHA256.file(File.join(root, "router/ROUTING_CAMPAIGN.yml")).hexdigest,
        "routing_cases_sha256" => Digest::SHA256.file(File.join(root, "router/ROUTING_CASES.yml")).hexdigest,
        "result_schema_sha256" => Digest::SHA256.file(File.join(root, "docs/ROUTING_EVAL_RESULT_SCHEMA.md")).hexdigest
      }
    }
  end

  def test_accepts_matching_handoff
    Dir.mktmpdir("routing-handoff") do |dir|
      input = File.join(dir, "HANDOFF.json")
      File.write(input, JSON.pretty_generate(valid_handoff(ROOT)))
      out, err, status = Open3.capture3(RbConfig.ruby, RUNNER, input, chdir: ROOT)
      assert status.success?, "#{out}
#{err}"
      assert_includes out, "repository content hashes: matched"
    end
  end

  def test_rejects_repository_content_drift
    Dir.mktmpdir("routing-handoff") do |dir|
      handoff = valid_handoff(ROOT)
      handoff["artifacts"]["routing_cases_sha256"] = "0" * 64
      input = File.join(dir, "HANDOFF.json")
      File.write(input, JSON.pretty_generate(handoff))
      _out, err, status = Open3.capture3(RbConfig.ruby, RUNNER, input, chdir: ROOT)
      refute status.success?
      assert_includes err, "routing_cases_sha256 mismatch"
    end
  end

  def test_generated_handoff_script_runs_verifier_before_campaign
    source = File.read(File.join(ROOT, "bin", "routing-campaign-handoff"), encoding: "UTF-8")
    assert_includes source, "routing-campaign-handoff-verify"
    assert_includes source, "HANDOFF.json"
    assert_includes source, "RESUME_ARGS"
    assert_includes source, "--resume"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_campaign_handoff_binding_system_test.rb"
  end
end
