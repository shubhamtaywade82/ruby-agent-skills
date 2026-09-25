# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

class RoutingModelMatrixCampaignSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  RUNNER = File.join(ROOT, "bin", "routing-model-matrix-campaign")

  def run_runner(*args)
    Open3.capture3(RbConfig.ruby, RUNNER, *args, chdir: ROOT)
  end

  def test_matrix_contract_is_explicit_and_non_ranking
    matrix = YAML.safe_load(File.read(File.join(ROOT, "router", "ROUTING_MODEL_MATRIX.yml"), encoding: "UTF-8"), permitted_classes: [], aliases: false)
    assert_equal 2, matrix.fetch("version")
    assert_equal "ollama", matrix.fetch("execution").fetch("provider")
    assert_equal true, matrix.fetch("controls").fetch("descriptive_comparison_only")
    assert_equal true, matrix.fetch("controls").fetch("no_synthetic_results")
  end

  def test_plan_mode_is_deterministic_and_does_not_require_runtime
    Dir.mktmpdir("routing-model-matrix") do |dir|
      out, err, status = run_runner(
        "--model", "model-a",
        "--model", "model-b",
        "--output", dir
      )
      assert status.success?, "#{out}
#{err}"

      plan = JSON.parse(File.read(File.join(dir, "matrix-plan.json"), encoding: "UTF-8"))
      assert_equal "plan", plan.fetch("mode")
      assert_equal ["model-a", "model-b"], plan.fetch("models").map { |m| m.fetch("name") }
      assert_equal 42, plan.fetch("campaign").fetch("expected_runs_per_model")
      assert plan.fetch("controls").fetch("descriptive_comparison_only")
      assert plan.fetch("controls").fetch("no_synthetic_results")
    end
  end

  def test_missing_models_is_rejected
    Dir.mktmpdir("routing-model-matrix") do |dir|
      _out, err, status = run_runner("--output", dir)
      refute status.success?
      assert_includes err, "no models supplied"
    end
  end

  def test_execute_requires_archive_destination
    Dir.mktmpdir("routing-model-matrix") do |dir|
      _out, err, status = run_runner("--model", "model-a", "--execute", "--output", dir)
      refute status.success?
      assert_includes err, "--archive is required"
    end
  end

  def test_resume_requires_existing_checkpoint
    Dir.mktmpdir("routing-model-matrix") do |dir|
      _out, err, status = run_runner(
        "--model", "model-a",
        "--execute",
        "--archive", File.join(dir, "archive"),
        "--output", dir,
        "--resume"
      )
      refute status.success?
      assert_includes err, "cannot resume without an existing matrix checkpoint"
    end
  end

  def test_resume_revalidates_completed_and_archived_results
    source = File.read(RUNNER, encoding: "UTF-8")
    completed_marker = 'existing_result["status"] == "completed_and_archived"'
    completed_index = source.index(completed_marker)
    refute_nil completed_index

    result_index = source.index("  result = {", completed_index)
    refute_nil result_index

    resume_block = source[completed_index, result_index - completed_index]
    assert_includes resume_block, "CAMPAIGN_EVIDENCE_VERIFY"
    assert_includes resume_block, "ARCHIVE_VERIFIER"
    assert_includes source, 'CAMPAIGN_EVIDENCE_VERIFY = File.join(ROOT, "bin", "routing-campaign-evidence-verify")'
    assert_includes source, 'ARCHIVE_VERIFIER = File.join(ROOT, "bin", "routing-archive-verify")'
  end

  def test_resume_flag_is_exposed
    source = File.read(RUNNER, encoding: "UTF-8")
    assert_includes source, "--resume"
    assert_includes source, "matrix checkpoint"
  end

  def test_resume_rejects_incompatible_checkpoint
    Dir.mktmpdir("routing-model-matrix") do |dir|
      checkpoint = {
        "protocol_version" => 1,
        "campaign" => {
          "id" => "skill-routing-public-v1",
          "version" => 1,
          "repetitions" => 99,
          "expected_runs_per_model" => 1386
        },
        "provenance" => {},
        "runtime" => {
          "provider" => "ollama",
          "url" => "http://127.0.0.1:11434",
          "timeout_seconds" => 300
        },
        "models" => [{"provider" => "ollama", "name" => "model-a", "status" => "failed"}],
        "controls" => {},
        "results" => []
      }
      File.write(File.join(dir, "matrix-plan.json"), JSON.pretty_generate(checkpoint))

      _out, err, status = run_runner(
        "--model", "model-a",
        "--runs", "3",
        "--execute",
        "--archive", File.join(dir, "archive"),
        "--output", dir,
        "--resume"
      )

      refute status.success?
      assert_includes err, "repetition mismatch"
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_model_matrix_campaign_system_test.rb"
  end
end
