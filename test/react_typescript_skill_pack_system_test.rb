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
      %w[Purpose Activate when Repository inspection Decision rules Implementation procedure Anti-patterns / failure modes Verification Source foundation].each do |section|
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
