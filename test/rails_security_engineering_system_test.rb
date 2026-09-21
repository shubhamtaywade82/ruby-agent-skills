# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsSecurityEngineeringSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-security-engineering/SKILL.md
    patterns/rails/threat-model.md
    patterns/rails/trust-boundary.md
    patterns/rails/authorization-matrix.md
    patterns/rails/tenant-isolation-review.md
    patterns/rails/secret-management-boundary.md
    patterns/rails/ssrf-outbound-boundary.md
    patterns/rails/dependency-supply-chain.md
    patterns/rails/security-regression.md
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_and_patterns
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))

    skill = manifest.fetch("skills").fetch("rails-security-engineering")
    assert_equal "skills/rails-security-engineering/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "threat model"
    assert_includes skill.fetch("triggers"), "tenant isolation"
    assert_includes skill.fetch("triggers"), "secret management"
    assert_includes skill.fetch("triggers"), "SSRF architecture"
    assert_includes skill.fetch("triggers"), "dependency supply chain"
    assert_includes skill.fetch("triggers"), "security regression"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.drop(1).each do |relative|
      assert_includes rails_patterns, relative
    end
  end

  def test_router_and_agent_contract_include_security_engineering_guidance
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Security engineering and threat modeling"
    assert_includes routing, "rails-security-engineering"
    assert_includes agents, "Security engineering and threat-model changes"
    assert_includes agents, "trust boundaries"
    assert_includes agents, "residual risk"
  end

  def test_security_evaluations_activate_engineering_skill
    %w[parameterized-query-boundary.yml authorization-boundary.yml].each do |filename|
      evaluation = YAML.safe_load(
        File.read(File.join(ROOT, "evals/security", filename), encoding: "UTF-8")
      )
      assert_includes evaluation.fetch("skills"), "rails-security-engineering"
    end
  end

  def test_skill_covers_architecture_level_security
    skill = File.read(File.join(ROOT, "skills/rails-security-engineering/SKILL.md"), encoding: "UTF-8")

    [
      "Threat-model procedure",
      "Trust boundaries",
      "Authorization architecture",
      "Tenant isolation",
      "Secrets and credentials",
      "SSRF and arbitrary outbound access",
      "Supply-chain security",
      "Security regression engineering",
      "Defense in depth",
      "Detection and response",
      "Residual risk and exceptions"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "assets"
    assert_includes skill, "attacker capabilities"
    assert_includes skill, "Do not treat authentication as authorization."
    assert_includes skill, "A passing scanner is evidence for the checks it performs, not a complete security assessment."
  end
end
