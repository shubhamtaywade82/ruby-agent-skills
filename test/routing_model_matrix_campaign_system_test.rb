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

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_model_matrix_campaign_system_test.rb"
  end
end
