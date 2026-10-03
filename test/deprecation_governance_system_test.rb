# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "yaml"

class DeprecationGovernanceSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  EXPECTED_SKILLS = %w[
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

  def test_manifest_declares_the_frontend_deprecation_boundary
    manifest = YAML.safe_load(File.read(manifest_path, encoding: "UTF-8"))
    entries = manifest.fetch("deprecations")

    assert_equal EXPECTED_SKILLS.sort, entries.keys.sort
    entries.each { |skill, entry| assert_valid_entry(skill, entry) }
  end

  def test_validator_accepts_the_repository_deprecation_registry
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "scripts", "validate_deprecations.rb"),
      chdir: ROOT
    )

    assert_predicate status, :success?, "#{stdout}\n#{stderr}"
    assert_includes stdout, "Validated 9 deprecation entries."
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validator, "scripts/validate_deprecations.rb"
    assert_includes validator, "test/deprecation_governance_system_test.rb"
  end

  private

  def manifest_path
    File.join(ROOT, "skill-manifest.yml")
  end

  def assert_valid_entry(skill, entry)
    assert_equal "deprecated", entry.fetch("status"), skill
    assert_equal "new_standalone_react_typescript_work", entry.fetch("scope"), skill
    assert_match %r{\Areact-agent-skills / .+}, entry.fetch("replacement"), skill
    assert_equal "docs/REACT_AGENT_SKILLS_MIGRATION.md", entry.fetch("migration_doc"), skill
    assert_equal 5, Array(entry.fetch("removal_gate")).length, skill
    assert(File.file?(File.join(ROOT, entry.fetch("migration_doc"))))
  end
end
