# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsPerformanceSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-performance/SKILL.md
    patterns/rails/n-plus-one-review.md
    patterns/rails/query-plan-evidence.md
    patterns/rails/connection-pool-capacity.md
    patterns/rails/cache-stampede-control.md
    evals/performance/performance-allocation-boundary.yml
    evals/performance/cache-key-boundary.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_the_rails_performance_skill
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))

    entry = manifest.fetch("skills").fetch("rails-performance")

    assert_equal "skills/rails-performance/SKILL.md", entry.fetch("path")
    assert_includes entry.fetch("triggers"), "Rails performance"
    assert_includes entry.fetch("triggers"), "N+1"
    assert_includes entry.fetch("triggers"), "connection pool"
  end

  def test_existing_performance_evals_cover_the_rails_skill
    Dir[File.join(ROOT, "evals/performance/*.yml")].each do |file|
      evaluation = YAML.safe_load(File.read(file, encoding: "UTF-8"))
      assert_includes evaluation.fetch("skills"), "rails-performance"
    end
  end

  def test_manifest_exposes_all_new_patterns
    patterns = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
      .fetch("patterns").fetch("rails").fetch("paths")

    REQUIRED_PATHS.grep(%r{\Apatterns/}).each do |relative|
      assert_includes patterns, relative
    end
  end
end
