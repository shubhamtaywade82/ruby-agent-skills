# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsActionViewSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-action-view/SKILL.md
    patterns/rails/action-view-partial-contract.md
    patterns/rails/action-view-strict-locals.md
    patterns/rails/action-view-output-safety.md
    patterns/rails/action-view-layout-contract.md
    patterns/rails/action-view-helper-boundary.md
    patterns/rails/action-view-render-performance.md
    patterns/rails/action-view-localized-template.md
    patterns/rails/action-view-testing.md
    evals/rails/action-view-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-action-view")

    assert_equal "skills/rails-action-view/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "Action View"
    assert_includes skill.fetch("triggers"), "strict locals"
    assert_includes skill.fetch("triggers"), "output safety"
    assert_includes skill.fetch("triggers"), "localized views"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      action-view-partial-contract
      action-view-strict-locals
      action-view-output-safety
      action-view-layout-contract
      action-view-helper-boundary
      action-view-render-performance
      action-view-localized-template
    ].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/rails/action-view-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-action-view").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/action-view-contract.yml"
  end

  def test_router_and_agent_contract_include_action_view
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Action View"
    assert_includes routing, "rails-action-view"
    assert_includes routing, "action-view-output-safety"
    assert_includes agents, "Rails Action View changes"
    assert_includes agents, "strict locals"
    assert_includes agents, "output safety"
    assert_includes agents, "localized template"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/action-view-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-action-view"
    assert_includes evaluation.fetch("skills"), "rails-security"
    assert_includes evaluation.fetch("skills"), "rails-i18n"
    assert_includes evaluation.fetch("patterns"), "action-view-output-safety"
    assert_includes evaluation.fetch("patterns"), "action-view-render-performance"
    assert_includes evaluation.fetch("patterns"), "action-view-testing"
  end

  def test_skill_covers_action_view_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-action-view/SKILL.md"), encoding: "UTF-8")

    [
      "Rendering boundary",
      "Template and lookup contract",
      "Partial contract",
      "Strict locals",
      "Layout boundary",
      "Helper boundary",
      "Output safety and sanitization",
      "Forms and tag helpers",
      "Localization",
      "Rendering performance",
      "Caching interaction",
      "Security and privacy",
      "Testing"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Never mark user input HTML-safe"
    assert_includes skill, "Do not use locale-specific templates as an authorization mechanism."
    assert_includes skill, "Never cache a private fragment under a key shared across tenants or authorization scopes."
    assert_includes skill, "Do not make ordinary rendering tests depend on external network services."
  end
end
