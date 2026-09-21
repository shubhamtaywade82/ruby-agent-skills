# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsAssociationsSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-associations/SKILL.md
    patterns/rails/association-cardinality-contract.md
    patterns/rails/association-inverse-contract.md
    patterns/rails/through-association-contract.md
    patterns/rails/polymorphic-association-boundary.md
    patterns/rails/association-dependent-lifecycle.md
    patterns/rails/association-autosave-contract.md
    patterns/rails/association-counter-touch-contract.md
    patterns/rails/association-callback-contract.md
    patterns/rails/association-loading-contract.md
    patterns/rails/association-testing.md
    evals/rails/associations-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-associations")

    assert_equal "skills/rails-associations/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "belongs_to"
    assert_includes skill.fetch("triggers"), "has_many"
    assert_includes skill.fetch("triggers"), "has_many :through"
    assert_includes skill.fetch("triggers"), "polymorphic"
    assert_includes skill.fetch("triggers"), "inverse_of"
    assert_includes skill.fetch("triggers"), "dependent"
    assert_includes skill.fetch("triggers"), "autosave"
    assert_includes skill.fetch("triggers"), "counter_cache"
    assert_includes skill.fetch("triggers"), "association callbacks"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      association-cardinality-contract
      association-inverse-contract
      through-association-contract
      polymorphic-association-boundary
      association-dependent-lifecycle
      association-autosave-contract
      association-counter-touch-contract
      association-callback-contract
      association-loading-contract
    ].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/rails/association-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-associations").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/associations-contract.yml"
  end

  def test_router_and_agent_contract_include_associations
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Associations"
    assert_includes routing, "rails-associations"
    assert_includes routing, "association-cardinality-contract"
    assert_includes agents, "Rails Associations changes"
    assert_includes agents, "inverse_of"
    assert_includes agents, "through associations"
    assert_includes agents, "polymorphic"
    assert_includes agents, "dependent lifecycle"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/associations-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-associations"
    assert_includes evaluation.fetch("skills"), "rails-database-engineering"
    assert_includes evaluation.fetch("patterns"), "association-inverse-contract"
    assert_includes evaluation.fetch("patterns"), "through-association-contract"
    assert_includes evaluation.fetch("patterns"), "polymorphic-association-boundary"
    assert_includes evaluation.fetch("patterns"), "association-dependent-lifecycle"
    assert_includes evaluation.fetch("patterns"), "association-testing"
  end

  def test_skill_covers_association_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-associations/SKILL.md"), encoding: "UTF-8")

    [
      "Cardinality and ownership",
      "belongs_to contract",
      "has_one and uniqueness",
      "has_many collection semantics",
      "Through associations",
      "Polymorphic associations",
      "Inverse associations",
      "Autosave and nested persistence",
      "Dependent lifecycle",
      "Counter caches and touch",
      "Association callbacks",
      "Association extensions",
      "Loading and inverse-aware performance",
      "Security and tenant isolation",
      "Testing"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "An association does not itself establish authorization"
    assert_includes skill, "Do not model one-to-one semantics with has_one alone"
    assert_includes skill, "Do not accept arbitrary client-provided polymorphic type names"
    assert_includes skill, "Do not use association callbacks for"
    assert_includes skill, "Do not combine database cascading"
  end
end
