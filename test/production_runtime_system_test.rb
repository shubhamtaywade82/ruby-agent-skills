# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class ProductionRuntimeSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-production-runtime/SKILL.md
    patterns/rails/puma-capacity.md
    patterns/rails/graceful-shutdown.md
    patterns/rails/zero-downtime-release.md
    patterns/rails/runtime-config-contract.md
    patterns/rails/release-migration-gate.md
    data/production-runtime/tools.yml
    evals/runtime/puma-capacity.yml
    evals/runtime/graceful-shutdown.yml
    evals/runtime/zero-downtime-release.yml
    evals/runtime/config-contract.yml
    evals/runtime/migration-gate.yml
    benchmarks/production-runtime/fixtures.yml
    benchmarks/production-runtime/campaign.yml
    scripts/verify_production_runtime_eval.rb
  ].freeze

  def test_all_runtime_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_runtime_evaluations_reference_registered_skills_and_patterns
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml")))
    registered_skills = manifest.fetch("skills").keys

    Dir[File.join(ROOT, "evals/runtime/*.yml")].each do |file|
      evaluation = YAML.safe_load(File.read(file))
      evaluation.fetch("skills").each { |skill| assert_includes registered_skills, skill }
    end
  end
end
