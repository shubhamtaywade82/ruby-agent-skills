# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class ObservabilitySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-observability/SKILL.md
    patterns/rails/request-error-boundary.md
    patterns/rails/request-observability.md
    patterns/rails/health-endpoint.md
    patterns/rails/instrumentation-event.md
    data/observability/tools.yml
    evals/observability/error-boundary.yml
    evals/observability/request-correlation.yml
    evals/observability/instrumentation-event.yml
    evals/observability/health-semantics.yml
    benchmarks/observability/fixtures.yml
    benchmarks/observability/campaign.yml
    scripts/verify_observability_eval.rb
  ].freeze

  def test_all_observability_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_evaluation_files_reference_registered_skill
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml")))
    registered = manifest.fetch("skills").keys

    Dir[File.join(ROOT, "evals/observability/*.yml")].each do |file|
      evaluation = YAML.safe_load(File.read(file))
      assert_includes registered, "rails-observability"
      evaluation.fetch("skills").each { |skill| assert_includes registered, skill }
    end
  end
end
