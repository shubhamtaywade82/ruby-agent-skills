# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

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
    "react-accessibility-performance" =>
      "react-agent-skills / react-accessibility + react-performance",
    "react-architecture" => "react-agent-skills / react-architecture"
  }.freeze

  def test_manifest_marks_every_frontend_skill_deprecated
    manifest = File.read(File.join(ROOT, "skill-manifest.yml"))

    MAPPINGS.each do |skill, replacement|
      assert_includes manifest, "DEPRECATED: standalone frontend ownership moved to #{replacement}"
      assert_includes manifest, "  #{skill}:"
    end
  end

  # Agents select skills from the SKILL.md description, so the deprecation
  # must be visible there and not only as a manifest comment.
  def test_skill_descriptions_announce_deprecation_and_replacement
    MAPPINGS.each do |skill, replacement|
      skill_md = File.read(File.join(ROOT, "skills", skill, "SKILL.md"), encoding: "UTF-8")
      description = skill_md[/^description: (.*)$/, 1].to_s

      assert description.start_with?("DEPRECATED"),
             "#{skill} description must start with DEPRECATED"
      assert_includes description, replacement
    end
  end

  # A deprecated skill must not be selected for new work, so no routing
  # contract may expect it as a primary or secondary skill.
  def test_routing_cases_never_expect_a_deprecated_skill
    cases = YAML.safe_load_file(File.join(ROOT, "router", "ROUTING_CASES.yml")).fetch("cases")

    cases.each do |routing_case|
      expected = Array(routing_case["primary_skills"]) + Array(routing_case["secondary_skills"])

      assert_empty expected & MAPPINGS.keys,
                   "#{routing_case.fetch('id')} expects a deprecated skill"
    end
  end

  # Content that stays after removal may point at the React pack, but must not
  # depend on a deprecated in-pack skill; otherwise deletion breaks it.
  def test_retained_content_never_depends_on_a_deprecated_skill
    names = MAPPINGS.keys.join("|")
    removed = %r{/(?:skills/(?:#{names})|patterns/react-typescript|evals/react-typescript)/}
    retained = Dir[File.join(ROOT, "{skills,patterns,evals}", "**", "*.{md,yml}")].grep_v(removed)
    pattern = /(?<![a-z-])(?:#{names})(?![a-z-])/

    retained.each do |path|
      text = File.read(path, encoding: "UTF-8").gsub(%r{react-agent-skills / [a-z0-9+ -]+}, "")

      refute_match pattern, text, "#{path.delete_prefix("#{ROOT}/")} depends on a deprecated skill"
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
