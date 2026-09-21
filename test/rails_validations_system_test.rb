# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsValidationsSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-validations/SKILL.md
    patterns/rails/validation-boundary.md
    patterns/rails/validation-context-contract.md
    patterns/rails/validation-condition-contract.md
    patterns/rails/validation-uniqueness-database-contract.md
    patterns/rails/validation-associated-graph.md
    patterns/rails/validation-custom-validator.md
    patterns/rails/validation-strict-failure.md
    patterns/rails/validation-error-contract.md
    patterns/rails/validation-callback-boundary.md
    patterns/rails/validation-bypass-audit.md
    patterns/rails/validation-testing.md
    evals/rails/validations-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-validations")
    assert_equal "skills/rails-validations/SKILL.md", skill.fetch("path")

    %w[validation errors validation context uniqueness validates_associated validates_with strict validation custom validator validation bypass].each do |trigger|
      assert_includes skill.fetch("triggers").join(" "), trigger
    end

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      validation-boundary
      validation-context-contract
      validation-condition-contract
      validation-uniqueness-database-contract
      validation-associated-graph
      validation-custom-validator
      validation-strict-failure
      validation-error-contract
      validation-callback-boundary
      validation-bypass-audit
    ].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    assert_includes manifest.fetch("patterns").fetch("testing").fetch("paths"), "patterns/rails/validation-testing.md"
    assert_includes manifest.fetch("evaluations").fetch("rails-validations").fetch("paths"), "evals/rails/validations-contract.yml"
  end

  def test_router_and_agent_contract_include_validations
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")
    assert_includes routing, "Rails Validation deep engineering"
    assert_includes routing, "validation-uniqueness-database-contract"
    assert_includes agents, "Rails Validations changes"
    assert_includes agents, "validation contexts"
    assert_includes agents, "validation bypass"
  end

  def test_skill_covers_validation_contract
    skill = File.read(File.join(ROOT, "skills/rails-validations/SKILL.md"), encoding: "UTF-8")
    %w[
      Validation lifecycle
      Built-in validator selection
      Validation contexts
      Validation errors
      Custom validation methods
      Associated validation
      Uniqueness and concurrent invariants
      Strict validations
      Validation callbacks
      Validation bypass paths
      API, form, and controller integration
      Security and tenant isolation
      Verification
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Validation is not authorization"
    assert_includes skill, "A uniqueness validator improves feedback but does not create database uniqueness enforcement"
    assert_includes skill, "Do not use custom contexts to make ordinary save silently accept invalid domain states."
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(File.read(File.join(ROOT, "evals/rails/validations-contract.yml"), encoding: "UTF-8"))
    assert_includes evaluation.fetch("skills"), "rails-validations"
    assert_includes evaluation.fetch("skills"), "rails-active-record"
    assert_includes evaluation.fetch("skills"), "rails-database-engineering"
    assert_includes evaluation.fetch("patterns"), "validation-context-contract"
    assert_includes evaluation.fetch("patterns"), "validation-uniqueness-database-contract"
    assert_includes evaluation.fetch("patterns"), "validation-error-contract"
    assert_includes evaluation.fetch("patterns"), "validation-bypass-audit"
    assert_includes evaluation.fetch("patterns"), "validation-testing"
  end
end
