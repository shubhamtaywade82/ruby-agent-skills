# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class StackMinimalitySkillPackSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  SKILLS = %w[
    stack-minimality
    stack-minimality-review
    stack-minimality-audit
    stack-minimality-debt
    stack-minimality-evidence
    stack-minimality-help
  ].freeze

  PATTERN_FAMILY = "stack-minimality"
  EVAL_PREFIX = "stack-minimality-"

  def manifest
    YAML.safe_load(
      File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
  end

  def test_stack_minimality_skills_are_registered_and_routed
    data = manifest
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")

    SKILLS.each do |skill|
      assert File.file?(File.join(ROOT, "skills", skill, "SKILL.md"))
      assert data.fetch("skills").key?(skill)
      assert_includes routing, skill
    end
  end

  def test_skill_contracts_have_required_sections
    SKILLS.each do |skill|
      content = File.read(File.join(ROOT, "skills", skill, "SKILL.md"), encoding: "UTF-8")
      [
        "Purpose",
        "Activate when",
        "Repository inspection",
        "Decision rules",
        "Implementation procedure",
        "Anti-patterns / failure modes",
        "Agent review checklist",
        "Verification",
        "Source foundation"
      ].each do |section|
        assert_includes content, "## #{section}", "#{skill} missing #{section}"
      end
    end
  end

  def test_stack_minimality_patterns_are_registered
    paths = manifest.fetch("patterns").fetch(PATTERN_FAMILY).fetch("paths")
    assert_operator paths.length, :>=, 12
    paths.each { |path| assert File.file?(File.join(ROOT, path)) }
  end

  def test_stack_minimality_evaluations_are_registered
    entry = manifest.fetch("evaluations").fetch("stack-minimality")
    paths = Array(entry.fetch("paths"))
    assert_equal 13, paths.length
    paths.each { |path| assert File.file?(File.join(ROOT, path)) }
  end

  def test_all_stack_minimality_evaluations_have_required_contract_shape
    Dir[File.join(ROOT, "evals", "stack-minimality", "*.yml")].each do |path|
      data = YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
      assert_equal 1, data.fetch("version")
      assert_equal "stack-minimality", data.fetch("category")
      assert_operator data.fetch("skills").length, :>=, 1
      assert_operator data.fetch("cases").length, :>=, 2
      assert_equal %w[functional tests contract scope_control], data.fetch("checks")
    end
  end

  def test_project_minimality_contract_is_explicit
    content = File.read(
      File.join(ROOT, "skills", "stack-minimality", "SKILL.md"),
      encoding: "UTF-8"
    )

    %w[
      Rails
      Active Record
      PostgreSQL
      React
      TypeScript
      YAGNI
      security
      accessibility
      tests
    ].each do |term|
      assert_includes content, term
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/stack_minimality_system_test.rb"
  end
end
