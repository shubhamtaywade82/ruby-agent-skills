# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsArchitectureSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-architecture/SKILL.md
    patterns/rails/request-flow.md
    patterns/rails/dependency-direction-contract.md
    patterns/rails/controller-service-authorization-composition.md
    patterns/rails/policy-object-boundary.md
    patterns/rails/the-rails-way.md
  ].freeze

  # The Rails Way pattern frames the philosophy as a 5-step decision hierarchy
  # for AI coding assistants. The five steps are the load-bearing contract of
  # the pattern; if any drifts, the audit no longer matches the upstream
  # Rails Way document this pack is sourced from.
  THE_RAILS_WAY_DECISION_STEPS = [
    "Follow the convention",
    "Assign responsibilities correctly",
    "Protect correctness and security",
    "Verify behavior",
    "Deviate deliberately"
  ].freeze

  # The pattern maps the eight Rails Way anti-patterns to the existing skill
  # or pattern that catches each violation. These anchors must remain present
  # so the cross-reference is not silently broken by a refactor.
  THE_RAILS_WAY_ANTI_PATTERN_ANCHORS = [
    "custom repository layer around every Active Record model",
    "generic service classes for all business logic",
    "Writing SQL strings for ordinary CRUD",
    "Putting every rule in controllers",
    "Using callbacks to orchestrate the entire business process",
    "Relying exclusively on Rails validations for data integrity",
    "Building large abstractions before understanding the requirements",
    "Ignoring query performance because Active Record generates SQL"
  ].freeze

  def test_all_rails_architecture_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_the_rails_way_pattern_keeps_decision_hierarchy
    pattern = File.read(File.join(ROOT, "patterns/rails/the-rails-way.md"), encoding: "UTF-8")

    THE_RAILS_WAY_DECISION_STEPS.each do |step|
      assert_includes pattern, step,
                      "the-rails-way.md must keep the '#{step}' decision step"
    end
  end

  def test_the_rails_way_pattern_keeps_anti_pattern_table
    pattern = File.read(File.join(ROOT, "patterns/rails/the-rails-way.md"), encoding: "UTF-8")

    THE_RAILS_WAY_ANTI_PATTERN_ANCHORS.each do |anchor|
      assert_includes pattern, anchor,
                      "the-rails-way.md must keep the '#{anchor}' anti-pattern row"
    end
  end

  def test_the_rails_way_pattern_is_registered_in_manifest
    manifest = YAML.safe_load_file(
      File.join(ROOT, "skill-manifest.yml"),
      permitted_classes: [],
      aliases: false
    )
    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")

    assert_includes rails_patterns, "patterns/rails/the-rails-way.md",
                    "the-rails-way.md must be registered under the rails pattern family"
  end

  def test_rails_architecture_skill_references_the_rails_way_pattern
    skill = File.read(File.join(ROOT, "skills/rails-architecture/SKILL.md"), encoding: "UTF-8")

    # SKILL.md cannot link to repository paths (single-skill installs do not
    # ship the patterns/ catalog), so the skill references the pattern by name
    # in backticks. The pattern name is load-bearing.
    assert_includes skill, "`the-rails-way`",
                    "rails-architecture SKILL.md must reference the `the-rails-way` pattern by name"
  end
end
