# frozen_string_literal: true

require "minitest/autorun"
require "digest"
require "json"
require "open3"
require "tmpdir"

class RoutingCampaignEvidenceIntegritySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_verifier_enforces_raw_run_cardinality_and_preflight
    source = File.read(File.join(ROOT, "bin", "routing-campaign-evidence-verify"), encoding: "UTF-8")
    assert_includes source, 'raw_artifact_keys.length'
    assert_includes source, 'artifacts.key?("preflight")'
  end


  def test_verifier_accepts_42_hashed_raw_artifacts
    Dir.mktmpdir("campaign-evidence") do |dir|
      artifact_paths = {}
      %w[campaign routing_report routing_contract skill_manifest campaign_manifest routing_cases result_schema campaign_intake_schema preflight].each do |key|
        path = File.join(dir, "#{key}.txt")
        File.write(path, key)
        artifact_paths[key] = path
      end

      42.times do |index|
        path = File.join(dir, "raw-#{index + 1}.json")
        File.write(path, "{}")
        artifact_paths["raw_case_#{index + 1}"] = path
      end

      artifacts = artifact_paths.transform_values do |path|
        {
          "path" => path,
          "sha256" => Digest::SHA256.file(path).hexdigest,
          "bytes" => File.size(path)
        }
      end

      evidence = {
        "protocol_version" => 1,
        "evidence" => "skill-routing-campaign-v1",
        "campaign" => "skill-routing-public-v1",
        "campaign_version" => 1,
        "routing_case_count" => 14,
        "requested_repetitions" => 3,
        "requested_runs" => 42,
        "completed_runs" => 42,
        "repository" => {"git_sha" => "abc", "worktree_clean" => true},
        "agent" => {"provider" => "ollama", "model" => "test-model"},
        "campaign_metrics" => {},
        "analysis" => {},
        "artifacts" => artifacts,
        "intake" => {"verified" => true},
        "replay" => {"campaign_runner" => "bin/routing-campaign"}
      }

      evidence_path = File.join(dir, "evidence.json")
      File.write(evidence_path, JSON.pretty_generate(evidence))
      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-campaign-evidence-verify"),
        evidence_path,
        "--check-files",
        chdir: ROOT
      )
      assert status.success?, "#{stdout}\n#{stderr}"
      assert_includes stdout, "42/42"
    end
  end

  def test_archive_invokes_campaign_evidence_verifier
    source = File.read(File.join(ROOT, "bin", "routing-archive"), encoding: "UTF-8")
    assert_includes source, "routing-campaign-evidence-verify"
  end

  def test_import_invokes_campaign_evidence_verifier
    source = File.read(File.join(ROOT, "bin", "routing-campaign-import"), encoding: "UTF-8")
    assert_includes source, "routing-campaign-evidence-verify"
  end

  def test_validator_executes_this_system_test
    source = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes source, "test/routing_campaign_evidence_integrity_system_test.rb"
  end
end
