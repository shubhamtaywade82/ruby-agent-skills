# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "yaml"

class ReactTypescriptSkillPackSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  SKILLS = %w[
    typescript-core-engineering
    typescript-type-design
    typescript-runtime-contracts
    react-component-engineering
    react-state-effects
    react-data-fetching
    react-testing-engineering
    react-accessibility-performance
    react-architecture
  ].freeze

  def manifest
    YAML.safe_load(
      File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
  end

  def test_all_react_typescript_skills_are_registered_and_routed
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

      ["Purpose", "Activate when", "Repository inspection", "Decision rules", "Implementation procedure", "Anti-patterns / failure modes", "Agent review checklist", "Verification", "Source foundation"].each do |section|
        assert_includes content, "## #{section}", "#{skill} missing #{section}"
      end
    end
  end

  def test_react_typescript_patterns_are_registered
    paths = manifest.fetch("patterns").fetch("react-typescript").fetch("paths")

    assert_equal 24, paths.length
    paths.each { |path| assert File.file?(File.join(ROOT, path)) }
  end

  def test_react_typescript_evaluations_are_registered
    entries = manifest.fetch("evaluations").select { |name, _| name.to_s.start_with?("react-typescript-", "react-") }

    assert_equal 9, entries.length
    entries.each_value do |entry|
      Array(entry.fetch("paths")).each { |path| assert File.file?(File.join(ROOT, path)) }
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "test/react_typescript_skill_pack_system_test.rb"
  end
end

# The Rails side of the Rails <-> React boundary stays in this pack after the
# standalone React/TypeScript skills move to react-agent-skills, so it must
# not live in the react-typescript family that is scheduled for removal.
class RailsReactIntegrationOwnershipSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  PATTERNS = %w[
    rails-react-integration-mode rails-react-typed-api-contract
    rails-react-validation-error-mapping rails-react-csrf-session-fetch
    rails-react-pagination-contract
  ].freeze

  def manifest
    YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
  end

  def test_integration_skill_and_evaluation_are_outside_the_react_typescript_family
    data = manifest

    assert_equal "rails", data.dig("skills", "rails-react-integration", "family")
    assert_equal ["evals/rails-react-integration/rails-react-integration-contract.yml"],
                 data.dig("evaluations", "rails-react-integration", "paths")
  end

  def test_integration_patterns_are_registered_in_the_rails_family
    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")

    PATTERNS.each do |name|
      path = "patterns/rails/#{name}.md"

      assert_includes rails_patterns, path
      assert_match(/^family: rails$/, File.read(File.join(ROOT, path), encoding: "UTF-8"))
    end
  end
end
