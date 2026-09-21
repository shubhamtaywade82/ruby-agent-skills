# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsActiveModelSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-active-model/SKILL.md
    patterns/rails/active-model-boundary.md
    patterns/rails/active-model-attributes-contract.md
    patterns/rails/active-model-validation-contract.md
    patterns/rails/active-model-dirty-lifecycle.md
    patterns/rails/active-model-callback-boundary.md
    patterns/rails/active-model-conversion-contract.md
    patterns/rails/active-model-serialization-contract.md
    patterns/rails/active-model-testing.md
    evals/rails/active-model-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-active-model")

    assert_equal "skills/rails-active-model/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "Active Model"
    assert_includes skill.fetch("triggers"), "ActiveModel::Model"
    assert_includes skill.fetch("triggers"), "ActiveModel::Attributes"
    assert_includes skill.fetch("triggers"), "ActiveModel::Dirty"
    assert_includes skill.fetch("triggers"), "ActiveModel::Callbacks"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      active-model-boundary
      active-model-attributes-contract
      active-model-validation-contract
      active-model-dirty-lifecycle
      active-model-callback-boundary
      active-model-conversion-contract
      active-model-serialization-contract
    ].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/rails/active-model-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-active-model").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/active-model-contract.yml"
  end

  def test_router_and_agent_contract_include_active_model
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Active Model"
    assert_includes routing, "rails-active-model"
    assert_includes routing, "active-model-boundary"
    assert_includes agents, "Rails Active Model changes"
    assert_includes agents, "ActiveModel::Model"
    assert_includes agents, "validation is authorization"
    assert_includes agents, "Active Model lint"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/active-model-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-active-model"
    assert_includes evaluation.fetch("skills"), "rails-validations"
    assert_includes evaluation.fetch("patterns"), "active-model-attributes-contract"
    assert_includes evaluation.fetch("patterns"), "active-model-conversion-contract"
    assert_includes evaluation.fetch("patterns"), "active-model-serialization-contract"
  end

  def test_skill_covers_active_model_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-active-model/SKILL.md"), encoding: "UTF-8")

    [
      "Boundary selection",
      "Model API contract",
      "Attributes and type semantics",
      "Validation and errors",
      "Conversion and naming",
      "Dirty tracking",
      "Callbacks",
      "Serialization",
      "Translation",
      "Form/input objects",
      "Active Model versus Active Record",
      "Security and privacy",
      "Testing and linting"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Do not use Active Model as a lightweight Active Record replacement."
    assert_includes skill, "Never treat validation success as authorization."
    assert_includes skill, "Do not treat Dirty as proof of persistence."
    assert_includes skill, "Do not serialize every attribute by default."
  end
end
