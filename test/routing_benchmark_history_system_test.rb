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

  def test_history_indexes_campaign_archives_without_ranking
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
          "artifacts" => {"campaign" => {}}
        )
      )
      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, File.join(ROOT, "bin", "routing-history"), dir, chdir: ROOT
      )
      assert status.success?, "#{stdout}\n#{stderr}"
      history = JSON.parse(stdout)
      assert_equal 1, history.fetch("campaign_count")
    end
  end

  def test_model_report_declares_descriptive_only
    source = File.read(File.join(ROOT, "bin", "routing-model-matrix-report"), encoding: "UTF-8")
    assert_includes source, '"comparison" => "descriptive-only"'
    refute_includes source, "winner"
    refute_includes source, "ranking"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_benchmark_history_system_test.rb"
  end
end
