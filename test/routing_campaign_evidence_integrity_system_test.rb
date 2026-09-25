# frozen_string_literal: true

require "minitest/autorun"
require "digest"
require "fileutils"
require "json"
require "open3"
require "tmpdir"
require "yaml"

class RoutingCampaignEvidenceIntegritySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_verifier_enforces_raw_run_cardinality_and_preflight
    source = File.read(File.join(ROOT, "bin", "routing-campaign-evidence-verify"), encoding: "UTF-8")
    assert_includes source, 'raw_artifact_keys.length'
    assert_includes source, 'artifacts.key?("preflight")'
  end


  def test_verifier_accepts_42_hashed_raw_artifacts
    Dir.mktmpdir("campaign-evidence") do |dir|
      campaign_path = File.join(dir, "campaign.json")
      report_path = File.join(dir, "routing-report.json")
      campaign = build_complete_campaign(dir)
      File.write(campaign_path, JSON.pretty_generate(campaign) + "\n", encoding: "UTF-8")

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-analyze"),
        campaign_path,
        "--output", report_path,
        chdir: ROOT
      )
      assert status.success?, "#{stdout}\n#{stderr}"
      report = JSON.parse(File.read(report_path, encoding: "UTF-8"))

      artifact_paths = {
        "campaign" => campaign_path,
        "routing_report" => report_path
      }
      %w[routing_contract skill_manifest campaign_manifest routing_cases result_schema campaign_intake_schema preflight].each do |key|
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
        "agent" => campaign.fetch("agent"),
        "campaign_metrics" => campaign.fetch("metrics"),
        "analysis" => report.fetch("summary"),
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


  def test_packager_rejects_tampered_analysis_report
    Dir.mktmpdir("routing-analysis-integrity") do |dir|
      campaign_path = File.join(dir, "campaign.json")
      preflight_path = File.join(dir, "preflight.json")
      report_path = File.join(dir, "routing-report.json")

      campaign = build_complete_campaign(dir)
      File.write(campaign_path, JSON.pretty_generate(campaign) + "\n", encoding: "UTF-8")
      File.write(preflight_path, JSON.pretty_generate(build_preflight(campaign)) + "\n", encoding: "UTF-8")

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-analyze"),
        campaign_path,
        "--output", report_path,
        chdir: ROOT
      )
      assert status.success?, "#{stdout}\n#{stderr}"

      report = JSON.parse(File.read(report_path, encoding: "UTF-8"))
      report.fetch("summary")["primary_accuracy"] = 0.0
      File.write(report_path, JSON.pretty_generate(report) + "\n", encoding: "UTF-8")

      _stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-campaign-evidence"),
        dir,
        chdir: ROOT
      )

      refute status.success?
      assert_includes stderr, "routing analysis verification failed"
    end
  end

  private

  def build_complete_campaign(dir)
    cases = YAML.safe_load(
      File.read(File.join(ROOT, "router", "ROUTING_CASES.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    ).fetch("cases")
    campaign_config = YAML.safe_load(
      File.read(File.join(ROOT, "router", "ROUTING_CAMPAIGN.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
    repetitions = campaign_config.fetch("execution").fetch("repetitions").to_i
    routing_inputs = {
      "manifest_sha256" => Digest::SHA256.file(File.join(ROOT, "skill-manifest.yml")).hexdigest,
      "campaign_manifest_sha256" => Digest::SHA256.file(File.join(ROOT, "router", "ROUTING_CAMPAIGN.yml")).hexdigest,
      "routing_cases_sha256" => Digest::SHA256.file(File.join(ROOT, "router", "ROUTING_CASES.yml")).hexdigest,
      "routing_contract_sha256" => Digest::SHA256.file(File.join(ROOT, "router", "ROUTING.md")).hexdigest
    }

    results = {}
    confusion_matrix = {}

    cases.each do |entry|
      primary = entry.fetch("primary_skills").first
      secondary = Array(entry.fetch("secondary_skills"))
      runs = []

      repetitions.times do |index|
        run_dir = File.join(dir, entry.fetch("id"), "run-#{index + 1}")
        FileUtils.mkdir_p(run_dir)
        raw_result_file = File.join(run_dir, "result.json")
        File.write(
          raw_result_file,
          JSON.pretty_generate(
            "primary_skill" => primary,
            "secondary_skills" => secondary,
            "reason" => "fixture"
          ) + "\n",
          encoding: "UTF-8"
        )

        runs << {
          "run_number" => index + 1,
          "status" => "completed",
          "expected" => {
            "primary_skill" => primary,
            "secondary_skills" => secondary,
            "boundary" => entry.fetch("boundary")
          },
          "observed" => {
            "primary_skill" => primary,
            "secondary_skills" => secondary,
            "reason" => "fixture"
          },
          "scoring" => {
            "primary_accuracy" => true,
            "secondary_recall" => 1.0,
            "unexpected_secondary_count" => 0
          },
          "validation_errors" => [],
          "raw_result_file" => raw_result_file
        }
      end

      results[entry.fetch("id")] = {
        "case_id" => entry.fetch("id"),
        "requested_repetitions" => repetitions,
        "completed_repetitions" => repetitions,
        "complete" => true,
        "expected_primary_skill" => primary,
        "runs" => runs
      }
      confusion_matrix[primary] = {primary => repetitions}
    end

    {
      "protocol_version" => 1,
      "evaluation" => "skill-routing-v1",
      "campaign" => campaign_config.fetch("id"),
      "campaign_version" => campaign_config.fetch("version"),
      "routing_contract" => File.join(ROOT, "router", "ROUTING.md"),
      "agent" => {
        "provider" => "ollama",
        "model" => "fixture-model",
        "model_version" => "fixture-digest",
        "tool_mode" => "local-filesystem"
      },
      "routing_case_count" => cases.length,
      "requested_repetitions" => repetitions,
      "requested_runs" => cases.length * repetitions,
      "completed_runs" => cases.length * repetitions,
      "complete" => true,
      "execution" => {"checkpointed" => true, "mode" => "fixture"},
      "routing_inputs" => routing_inputs,
      "metrics" => {
        "primary_accuracy" => 1.0,
        "secondary_recall" => 1.0,
        "average_unexpected_secondary_count" => 0.0
      },
      "confusion_matrix" => confusion_matrix,
      "cases" => results
    }
  end

  def build_preflight(campaign)
    campaign_config = YAML.safe_load(
      File.read(File.join(ROOT, "router", "ROUTING_CAMPAIGN.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
    cases = YAML.safe_load(
      File.read(File.join(ROOT, "router", "ROUTING_CASES.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    ).fetch("cases")
    git_sha, git_status = Open3.capture2("git", "-C", ROOT, "rev-parse", "HEAD")
    raise "unable to resolve Git SHA" unless git_status.success?

    {
      "protocol_version" => 1,
      "preflight" => "skill-routing-preflight-v1",
      "campaign" => {
        "id" => campaign_config.fetch("id"),
        "version" => campaign_config.fetch("version"),
        "evaluation_set" => campaign_config.fetch("evaluation_set"),
        "case_count" => cases.length,
        "repetitions" => campaign.fetch("requested_repetitions"),
        "expected_runs" => campaign.fetch("requested_runs")
      },
      "runtime" => {
        "provider" => "ollama",
        "url" => "http://fixture",
        "version" => {"version" => "fixture"},
        "model" => {
          "name" => campaign.dig("agent", "model"),
          "digest" => campaign.dig("agent", "model_version"),
          "size" => 1,
          "modified_at" => "fixture"
        }
      },
      "execution" => {
        "timeout_seconds" => 1,
        "fresh_workspace_per_run" => true,
        "same_command_for_all_runs" => true
      },
      "repository" => {
        "git_sha" => git_sha.strip,
        "manifest_sha256" => Digest::SHA256.file(File.join(ROOT, "skill-manifest.yml")).hexdigest,
        "campaign_manifest_sha256" => Digest::SHA256.file(File.join(ROOT, "router", "ROUTING_CAMPAIGN.yml")).hexdigest,
        "routing_cases_sha256" => Digest::SHA256.file(File.join(ROOT, "router", "ROUTING_CASES.yml")).hexdigest,
        "routing_contract_sha256" => Digest::SHA256.file(File.join(ROOT, "router", "ROUTING.md")).hexdigest
      }
    }
  end

  def test_validator_executes_this_system_test
    source = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes source, "test/routing_campaign_evidence_integrity_system_test.rb"
  end
end
