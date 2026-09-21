# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class DatabaseEngineeringSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-database-engineering/SKILL.md
    patterns/rails/expand-contract-migration.md
    patterns/rails/production-index.md
    patterns/rails/database-constraint.md
    patterns/rails/batched-backfill.md
    patterns/rails/transaction-lock-boundary.md
    data/database-engineering/tools.yml
    evals/database/expand-contract.yml
    evals/database/concurrent-index.yml
    evals/database/constraint.yml
    evals/database/batched-backfill.yml
    evals/database/transaction-lock.yml
    benchmarks/database-engineering/fixtures.yml
    benchmarks/database-engineering/campaign.yml
    scripts/verify_database_engineering_eval.rb
  ].freeze

  def test_all_database_engineering_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_database_evaluations_reference_registered_skill
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml")))
    registered = manifest.fetch("skills").keys

    Dir[File.join(ROOT, "evals/database/*.yml")].each do |file|
      evaluation = YAML.safe_load(File.read(file))
      evaluation.fetch("skills").each { |skill| assert_includes registered, skill }
    end
  end
end
