# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "fileutils"
require "tmpdir"

class RoutingBenchmarkHistorySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_history_rejects_unverifiable_campaign_archives
    Dir.mktmpdir("routing-history") do |dir|
      archive = File.join(dir, "skill-routing-public-v1", "model-a", "sha")
      FileUtils.mkdir_p(archive)
      File.write(
        File.join(archive, "ARCHIVE_MANIFEST.json"),
        JSON.generate(
          "archive_id" => "skill-routing-public-v1/model-a/sha",
          "captured_at" => "2026-09-23T00:00:00Z",
          "evidence_type" => "skill-routing-campaign-v1",
          "repository" => {"git_sha" => "sha", "worktree_clean" => true},
          "agent" => {"provider" => "ollama", "model" => "model-a"},
          "campaign_metrics" => {"primary_accuracy" => 0.5, "secondary_recall" => 0.4},
          "requested_runs" => 42,
          "completed_runs" => 42,
          "analysis" => {},
          "artifacts" => {}
        )
      )

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, File.join(ROOT, "bin", "routing-history"), dir, chdir: ROOT
      )

      refute status.success?
      assert_includes stderr, "archive verification failed"
      assert_equal "", stdout
    end
  end

  def test_history_indexes_verified_campaign_archives_without_ranking
    Dir.mktmpdir("routing-history") do |dir|
      create_verified_archive(dir)

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, File.join(ROOT, "bin", "routing-history"), dir, chdir: ROOT
      )

      assert status.success?, "#{stdout}\n#{stderr}"
      history = JSON.parse(stdout)
      assert_equal 1, history.fetch("campaign_count")
      entry = history.fetch("entries").first
      assert_equal true, entry.fetch("verified")
      assert_equal "bin/routing-archive-verify", entry.fetch("verifier")
      assert_equal "skill-routing-public-v1", entry.fetch("campaign")
    end
  end

  def test_history_rejects_tampered_archived_manifest
    Dir.mktmpdir("routing-history") do |dir|
      create_verified_archive(dir)
      manifest_path = Dir[File.join(dir, "**", "ARCHIVE_MANIFEST.json")].fetch(0)
      manifest = JSON.parse(File.read(manifest_path, encoding: "UTF-8"))
      manifest["campaign_metrics"]["primary_accuracy"] = 0.0
      File.write(manifest_path, JSON.pretty_generate(manifest) + "\n", encoding: "UTF-8")

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, File.join(ROOT, "bin", "routing-history"), dir, chdir: ROOT
      )

      refute status.success?
      assert_includes stderr, "archive verification failed"
      assert_equal "", stdout
    end
  end

  def test_history_rejects_tampered_archived_artifact
    Dir.mktmpdir("routing-history") do |dir|
      create_verified_archive(dir)
      campaign_copy = Dir[File.join(dir, "**", "artifacts", "*campaign--campaign.json")].fetch(0)
      File.write(campaign_copy, File.read(campaign_copy, encoding: "UTF-8").sub('"completed_runs": 42', '"completed_runs": 41'), encoding: "UTF-8")

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, File.join(ROOT, "bin", "routing-history"), dir, chdir: ROOT
      )

      refute status.success?
      assert_includes stderr, "archive verification failed"
      assert_equal "", stdout
    end
  end

  def test_history_uses_archive_verifier
    source = File.read(File.join(ROOT, "bin", "routing-history"), encoding: "UTF-8")
    assert_includes source, "routing-archive-verify"
    assert File.file?(File.join(ROOT, "bin", "routing-archive-verify"))
  end

  def test_archived_verification_uses_archived_contract_inputs
    verifier = File.read(File.join(ROOT, "bin", "routing-campaign-evidence-verify"), encoding: "UTF-8")
    assert_includes verifier, "--campaign-config PATH"
    assert_includes verifier, "--routing-cases PATH"
    assert_includes verifier, "--skill-manifest PATH"

    analyzer = File.read(File.join(ROOT, "bin", "routing-analyze"), encoding: "UTF-8")
    assert_includes analyzer, "--manifest PATH"
  end

  def test_model_report_declares_descriptive_only
    source = File.read(File.join(ROOT, "bin", "routing-model-matrix-report"), encoding: "UTF-8")
    assert_includes source, '"comparison" => "descriptive-only"'
    refute_includes source, "winner"
    refute_includes source, "ranking"
  end

  private

  def create_verified_archive(root)
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

    source_dir = File.join(root, "source")
    FileUtils.mkdir_p(source_dir)
    campaign_path = File.join(source_dir, "campaign.json")
    preflight_path = File.join(source_dir, "preflight.json")
    routing_report_path = File.join(source_dir, "routing-report.json")

    artifacts_source = {
      "routing_contract" => File.join(source_dir, "routing-contract.md"),
      "skill_manifest" => File.join(ROOT, "skill-manifest.yml"),
      "campaign_manifest" => File.join(ROOT, "router", "ROUTING_CAMPAIGN.yml"),
      "routing_cases" => File.join(ROOT, "router", "ROUTING_CASES.yml"),
      "result_schema" => File.join(ROOT, "docs", "ROUTING_EVAL_RESULT_SCHEMA.md"),
      "campaign_intake_schema" => File.join(ROOT, "docs", "ROUTING_CAMPAIGN_INTAKE_SCHEMA.md"),
      "preflight" => preflight_path
    }
    File.write(artifacts_source.fetch("routing_contract"), "# fixture\n", encoding: "UTF-8")
    File.write(preflight_path, "{}\n", encoding: "UTF-8")

    results = {}
    cases.each do |entry|
      primary = entry.fetch("primary_skills").first
      secondary = Array(entry.fetch("secondary_skills"))
      runs = 3.times.map do |index|
        raw_path = File.join(source_dir, "raw-#{entry.fetch("id")}-#{index + 1}.json")
        File.write(raw_path, "{}\n", encoding: "UTF-8")
        {
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
          "raw_result_file" => raw_path
        }
      end
      results[entry.fetch("id")] = {
        "case_id" => entry.fetch("id"),
        "requested_repetitions" => 3,
        "completed_repetitions" => 3,
        "complete" => true,
        "expected_primary_skill" => primary,
        "runs" => runs
      }
    end

    campaign = {
      "protocol_version" => 1,
      "evaluation" => "skill-routing-v1",
      "campaign" => campaign_config.fetch("id"),
      "campaign_version" => campaign_config.fetch("version"),
      "routing_contract" => artifacts_source.fetch("routing_contract"),
      "agent" => {"provider" => "ollama", "model" => "fixture-model", "model_version" => "fixture-digest", "tool_mode" => "local-filesystem"},
      "routing_case_count" => cases.length,
      "requested_repetitions" => 3,
      "requested_runs" => 42,
      "completed_runs" => 42,
      "complete" => true,
      "execution" => {"checkpointed" => true, "mode" => "fixture"},
      "routing_inputs" => {},
      "metrics" => {"primary_accuracy" => 1.0, "secondary_recall" => 1.0, "average_unexpected_secondary_count" => 0.0},
      "confusion_matrix" => {},
      "cases" => results
    }
    File.write(campaign_path, JSON.pretty_generate(campaign) + "\n", encoding: "UTF-8")

    out, err, status = Open3.capture3(
      RbConfig.ruby, File.join(ROOT, "bin", "routing-analyze"), campaign_path,
      "--output", routing_report_path, chdir: ROOT
    )
    raise "#{out}\n#{err}" unless status.success?

    artifacts_source["campaign"] = campaign_path
    artifacts_source["routing_report"] = routing_report_path
    artifacts_source.keys.select { |key| key.start_with?("raw_") }.each { |key| artifacts_source.delete(key) }
    raw_paths = Dir[File.join(source_dir, "raw-*.json")]
    raw_paths.each_with_index { |path, index| artifacts_source["raw_case_#{index + 1}"] = path }

    artifacts = artifacts_source.transform_values do |path|
      {
        "path" => path,
        "sha256" => Digest::SHA256.file(path).hexdigest,
        "bytes" => File.size(path)
      }
    end
    evidence = {
      "protocol_version" => 1,
      "evidence" => "skill-routing-campaign-v1",
      "campaign" => campaign.fetch("campaign"),
      "campaign_version" => campaign.fetch("campaign_version"),
      "routing_case_count" => 14,
      "requested_repetitions" => 3,
      "requested_runs" => 42,
      "completed_runs" => 42,
      "repository" => {"git_sha" => "sha", "worktree_clean" => true},
      "agent" => campaign.fetch("agent"),
      "campaign_metrics" => campaign.fetch("metrics"),
      "analysis" => JSON.parse(File.read(routing_report_path, encoding: "UTF-8")).fetch("summary"),
      "artifacts" => artifacts,
      "intake" => {"verified" => true},
      "replay" => {"campaign_runner" => "bin/routing-campaign"}
    }
    evidence_path = File.join(source_dir, "evidence.json")
    File.write(evidence_path, JSON.pretty_generate(evidence) + "\n", encoding: "UTF-8")

    archive_root = File.join(root, "archive")
    out, err, status = Open3.capture3(
      RbConfig.ruby, File.join(ROOT, "bin", "routing-archive"), evidence_path,
      "--destination", archive_root, chdir: ROOT
    )
    raise "#{out}\n#{err}" unless status.success?

    {archive: Dir[File.join(archive_root, "**", "ARCHIVE_MANIFEST.json")].first}
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_benchmark_history_system_test.rb"
  end
end
