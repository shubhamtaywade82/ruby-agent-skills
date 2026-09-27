# frozen_string_literal: true

require "minitest/autorun"

class ReactAgentSkillsDeprecationTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  MAPPINGS = {
    "typescript-core-engineering" => "react-agent-skills / typescript-core-engineering",
    "typescript-type-design" => "react-agent-skills / typescript-type-design",
    "typescript-runtime-contracts" => "react-agent-skills / typescript-runtime-contracts",
    "react-component-engineering" => "react-agent-skills / react-component-engineering",
    "react-state-effects" => "react-agent-skills / react-hooks-effects + react-state-management",
    "react-data-fetching" => "react-agent-skills / react-data-fetching",
    "react-testing-engineering" => "react-agent-skills / react-testing-engineering + frontend-e2e",
    "react-accessibility-performance" => "react-agent-skills / react-accessibility + react-performance",
    "react-architecture" => "react-agent-skills / react-architecture"
  }.freeze

  def test_manifest_marks_every_frontend_skill_deprecated
    manifest = File.read(File.join(ROOT, "skill-manifest.yml"))

    MAPPINGS.each do |skill, replacement|
      assert_includes manifest, "DEPRECATED: standalone frontend ownership moved to #{replacement}"
      assert_includes manifest, "  #{skill}:"
    end
  end

  def test_migration_document_exists_and_matches_the_mapping
    path = File.join(ROOT, "docs", "REACT_AGENT_SKILLS_MIGRATION.md")
    assert File.file?(path), "migration document must exist"

    document = File.read(path)
    MAPPINGS.each do |skill, replacement|
      assert_includes document, "| #{skill} | #{replacement} |"
    end

    assert_includes document, "Deletion is not part of this change."
  end
end
