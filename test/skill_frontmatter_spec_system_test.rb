# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"

class SkillFrontmatterSpecSystemTest < Minitest::Test
  # The fixture builder is intentionally verbose because this is a system-contract test.
  # rubocop:disable Metrics/ClassLength, Metrics/MethodLength, Metrics/BlockLength
  ROOT = File.expand_path("..", __dir__)

  def with_skill(frontmatter)
    Dir.mktmpdir("ruby-agent-skill-frontmatter-") do |root|
      FileUtils.mkdir_p(File.join(root, "skills", "example-skill"))
      File.write(
        File.join(root, "skills", "example-skill", "SKILL.md"),
        <<~MARKDOWN
          ---
          #{frontmatter}
          ---
          # Example Skill

          ## Purpose

          Use this skill for the example boundary.

          ## Activate when

          Activate when the task matches the example boundary.

          ## Repository inspection

          Inspect the repository and existing tests first.

          ## Agent review checklist

          - [ ] Existing conventions inspected

          ## Verification

          Run the relevant tests and report evidence.

          ## Source foundation

          Use repository and source-backed guidance.

          ## Failure modes

          Avoid guessing when evidence is missing.
        MARKDOWN
      )

      File.write(
        File.join(root, "skill-manifest.yml"),
        <<~YAML
          version: 2
          name: ruby-agent-skills

          defaults:
            agent_workflow: agent-workflow
            require_repository_inspection: true

          skills:
            example-skill:
              family: ruby
              path: skills/example-skill/SKILL.md
              triggers:
                - example boundary
        YAML
      )

      yield root
    end
  end

  def run_validator(root)
    Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "scripts", "validate_skills.rb"),
      "--root",
      root,
      chdir: ROOT
    )
  end

  def test_valid_frontmatter_with_optional_fields_passes
    with_skill(<<~YAML.strip) do |root|
      name: example-skill
      description: "Handles the example boundary and its verification workflow."
      license: Apache-2.0
      compatibility: "Requires Ruby 3.3+"
      metadata:
        owner: ruby-agent-skills
        version: "1"
      allowed-tools: "Read Bash(git:*)"
    YAML
      stdout, stderr, status = run_validator(root)

      assert_predicate status, :success?, "#{stdout}\n#{stderr}"
      assert_includes stdout, "Validated 1 skills."
    end
  end

  def test_name_must_match_agent_skills_naming_contract
    invalid_names = [
      "Example-skill",
      "example_skill",
      "example--skill",
      "example skill"
    ]

    invalid_names.each do |name|
      with_skill(<<~YAML.strip) do |root|
        name: "#{name}"
        description: "A valid description."
      YAML
        stdout, stderr, status = run_validator(root)

        message = "unexpectedly accepted #{name.inspect}: #{stdout}#{stderr}"

        refute_predicate status, :success?, message

        assert_includes stderr, "name must use lowercase letters, numbers, and single hyphens"
      end
    end
  end

  def test_name_maximum_length_is_enforced
    with_skill(<<~YAML.strip) do |root|
      name: "#{'a' * 65}"
      description: "A valid description."
    YAML
      _stdout, stderr, status = run_validator(root)

      refute_predicate status, :success?
      assert_includes stderr, "name must be <= 64 characters"
    end
  end

  def test_name_and_description_must_be_strings
    with_skill(<<~YAML.strip) do |root|
      name: 123
      description: 456
    YAML
      _stdout, stderr, status = run_validator(root)

      refute_predicate status, :success?
      assert_includes stderr, "name must be a non-empty string"
      assert_includes stderr, "description must be a non-empty string"
    end
  end

  def test_description_and_compatibility_length_limits_are_enforced
    long_description = "d" * 1025
    long_compatibility = "c" * 501

    with_skill(<<~YAML) do |root|
      name: example-skill
      description: #{long_description.inspect}
      compatibility: #{long_compatibility.inspect}
    YAML
      _stdout, stderr, status = run_validator(root)

      refute_predicate status, :success?
      assert_includes stderr, "description must be <= 1024 characters"
      assert_includes stderr, "compatibility must be <= 500 characters"
    end
  end

  def test_optional_frontmatter_types_are_validated
    with_skill(<<~YAML.strip) do |root|
      name: example-skill
      description: "A valid description."
      metadata:
        owner: 123
      license:
        - MIT
      allowed-tools:
        - Read
    YAML
      _stdout, stderr, status = run_validator(root)

      refute_predicate status, :success?
      messages = [
        "metadata must be a mapping of string keys to string values",
        "license must be a string",
        "allowed-tools must be a string"
      ]

      assert(messages.all? { |message| stderr.include?(message) })
    end
  end

  # rubocop:enable Metrics/ClassLength, Metrics/MethodLength, Metrics/BlockLength
end
