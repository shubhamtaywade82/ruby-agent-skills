# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsActiveSupportSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-active-support/SKILL.md
    patterns/rails/active-support-loading-boundary.md
    patterns/rails/active-support-concern-composition.md
    patterns/rails/active-support-class-configuration.md
    patterns/rails/active-support-current-context.md
    patterns/rails/active-support-notifications-contract.md
    patterns/rails/active-support-callback-boundary.md
    patterns/rails/active-support-time-semantics.md
    patterns/rails/active-support-inflection-boundary.md
    patterns/rails/active-support-testing.md
    evals/rails/active-support-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-active-support")

    assert_equal "skills/rails-active-support/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "Active Support"
    assert_includes skill.fetch("triggers"), "ActiveSupport::Concern"
    assert_includes skill.fetch("triggers"), "ActiveSupport::CurrentAttributes"
    assert_includes skill.fetch("triggers"), "ActiveSupport::Notifications"
    assert_includes skill.fetch("triggers"), "class_attribute"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      active-support-loading-boundary
      active-support-concern-composition
      active-support-class-configuration
      active-support-current-context
      active-support-notifications-contract
      active-support-callback-boundary
      active-support-time-semantics
      active-support-inflection-boundary
    ].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/rails/active-support-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-active-support").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/active-support-contract.yml"
  end

  def test_router_and_agent_contract_include_active_support
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Active Support"
    assert_includes routing, "rails-active-support"
    assert_includes routing, "active-support-notifications-contract"
    assert_includes agents, "Rails Active Support changes"
    assert_includes agents, "ActiveSupport::Concern"
    assert_includes agents, "CurrentAttributes"
    assert_includes agents, "notification payload"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/active-support-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-active-support"
    assert_includes evaluation.fetch("skills"), "rails-observability"
    assert_includes evaluation.fetch("skills"), "ruby-concurrency"
    assert_includes evaluation.fetch("patterns"), "active-support-current-context"
    assert_includes evaluation.fetch("patterns"), "active-support-notifications-contract"
    assert_includes evaluation.fetch("patterns"), "active-support-inflection-boundary"
  end

  def test_skill_covers_active_support_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-active-support/SKILL.md"), encoding: "UTF-8")

    [
      "Core extensions and loading",
      "ActiveSupport::Concern",
      "class_attribute and reusable configuration",
      "CurrentAttributes and execution context",
      "ActiveSupport::Callbacks",
      "ActiveSupport::Notifications",
      "Time and date semantics",
      "Inflection and dynamic constantization",
      "Security and concurrency",
      "Testing"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Do not use instrumentation as the business event bus."
    assert_includes skill, "Never assume CurrentAttributes automatically propagates into every background job"
    assert_includes skill, "Do not use class_attribute as hidden mutable global application state."
    assert_includes skill, "prefer an explicit allowlisted mapping"
  end
end
