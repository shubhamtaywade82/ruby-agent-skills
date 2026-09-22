# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class TestEngineeringSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-test-engineering/SKILL.md
    patterns/testing/test-boundary-selection.md
    patterns/testing/deterministic-async-test.md
    patterns/testing/parallel-safe-test.md
    patterns/testing/flaky-test-diagnosis.md
    patterns/testing/test-performance-budget.md
    patterns/testing/system-test-contract.md
    patterns/testing/request-contract.md
    patterns/testing/parallel-database-test.md
    data/test-engineering/tools.yml
    evals/test-engineering/boundary-selection.yml
    evals/test-engineering/deterministic-job.yml
    evals/test-engineering/parallel-safety.yml
    evals/test-engineering/flaky-diagnosis.yml
    evals/test-engineering/system-contract.yml
    evals/test-engineering/test-performance.yml
    benchmarks/test-engineering/fixtures.yml
    benchmarks/test-engineering/campaign.yml
    scripts/verify_test_engineering_eval.rb
  ].freeze

  def test_all_test_engineering_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_evaluations_reference_registered_skills
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml")))
    registered = manifest.fetch("skills").keys

    Dir[File.join(ROOT, "evals/test-engineering/*.yml")].each do |file|
      evaluation = YAML.safe_load(File.read(file))
      evaluation.fetch("skills").each { |skill| assert_includes registered, skill }
    end
  end
end
