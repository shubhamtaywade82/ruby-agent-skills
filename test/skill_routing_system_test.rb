# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "yaml"

class SkillRoutingSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_routing_quality_audit_passes
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "scripts", "audit_skill_routing.rb"),
      chdir: ROOT
    )

    assert status.success?, "#{stdout}\n#{stderr}"
    assert_includes stdout, "Skill routing quality audit passed."
  end

  def test_cases_reference_registered_skills
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    cases = YAML.safe_load(File.read(File.join(ROOT, "router", "ROUTING_CASES.yml"), encoding: "UTF-8"))
    skills = manifest.fetch("skills").keys

    Array(cases.fetch("cases")).each do |entry|
      (Array(entry.fetch("primary_skills")) + Array(entry.fetch("secondary_skills"))).each do |skill|
        assert_includes skills, skill
      end
    end
  end

  def test_agent_workflow_explains_primary_secondary_ownership
    workflow = File.read(
      File.join(ROOT, "skills", "agent-workflow", "SKILL.md"),
      encoding: "UTF-8"
    )

    assert_includes workflow, "Primary skill"
    assert_includes workflow, "Secondary skills"
    assert_includes workflow, "routing quality"
    assert_includes workflow, "Do not choose a skill only because a trigger token appears"
  end

  def test_routing_cases_cover_high_risk_overlaps
    cases = YAML.safe_load(
      File.read(File.join(ROOT, "router", "ROUTING_CASES.yml"), encoding: "UTF-8")
    )

    boundaries = Array(cases.fetch("cases")).map { |entry| entry.fetch("boundary") }

    %w[
      authentication-vs-authorization
      authorization-vs-background-execution
      api-vs-security
      performance-vs-persistence
      caching-vs-authorization
      encryption-vs-operations
    ].each { |boundary| assert_includes boundaries, boundary }
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/skill_routing_system_test.rb"
  end
end
