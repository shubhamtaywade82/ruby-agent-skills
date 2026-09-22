# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsCachingSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-caching/SKILL.md
    patterns/rails/cache-boundary.md
    patterns/rails/cache-key-isolation.md
    patterns/rails/cache-invalidation-contract.md
    patterns/rails/cache-stampede-control.md
    patterns/rails/cache-failure-boundary.md
    patterns/rails/cache-warming-strategy.md
    patterns/rails/cache-capacity-review.md
    evals/performance/cache-key-boundary.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_and_patterns
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-caching")

    assert_equal "skills/rails-caching/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "Rails caching"
    assert_includes skill.fetch("triggers"), "cache key isolation"
    assert_includes skill.fetch("triggers"), "cache invalidation"
    assert_includes skill.fetch("triggers"), "cache failure"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.drop(1).reject { |path| path.start_with?("evals/") }.each do |relative|
      assert_includes rails_patterns, relative
    end
  end

  def test_router_and_agent_contract_include_caching
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails caching engineering"
    assert_includes routing, "rails-caching"
    assert_includes routing, "cache-key-isolation"
    assert_includes agents, "Rails caching changes"
    assert_includes agents, "cache"
    assert_includes agents, "authoritative state transition"
  end

  def test_cache_evaluation_activates_caching_skill
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/performance/cache-key-boundary.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-caching"
    assert_includes evaluation.fetch("patterns"), "cache-key-isolation"
  end

  def test_skill_covers_cache_correctness_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-caching/SKILL.md"), encoding: "UTF-8")

    [
      "Cache suitability",
      "Cache layers",
      "Cache key contract",
      "Versioning and deployment",
      "Freshness and invalidation",
      "Miss behavior",
      "Stampede and hot keys",
      "Cache warming",
      "Failure behavior",
      "Capacity and eviction",
      "Security and isolation",
      "Observability",
      "Testing"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "A cache key is part of the data contract."
    assert_includes skill, "A short TTL is not a substitute for correct invalidation"
    assert_includes skill, "Never cache exceptions or authorization failures as successful values."
    assert_includes skill, "Do not add distributed locks because stampede is theoretically possible."
  end
end
