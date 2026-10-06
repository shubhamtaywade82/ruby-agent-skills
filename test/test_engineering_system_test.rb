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
    evals/test-engineering/rspec-request-contract.yml
    benchmarks/test-engineering/fixtures/rspec-request-contract/spec/requests/orders_spec.rb
    benchmarks/test-engineering/fixtures.yml
    benchmarks/test-engineering/campaign.yml
    scripts/verify_test_engineering_eval.rb
  ].freeze

  RSPEC_REFERENCE_RULES = [
    'describe "#instance_method"',
    'describe ".class_method"',
    "RSpec/DescribeMethod",
    ":aggregate_failures",
    "RSpec/MultipleExpectations",
    "WebMock.disable_net_connect!(allow_localhost: true)",
    "filter_sensitive_data",
    "Do not add WebMock or VCR to a suite that isolates HTTP another way"
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

  def test_rspec_reference_keeps_method_naming_aggregate_failures_and_http_stubbing_rules
    reference = File.read(File.join(ROOT, "skills/rails-test-engineering/references/rspec.md"))

    RSPEC_REFERENCE_RULES.each { |rule| assert_includes reference, rule }
  end
end
