# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsReliabilityEngineeringSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-reliability-engineering/SKILL.md
    patterns/rails/slo-error-budget.md
    patterns/rails/dependency-failure-boundary.md
    patterns/rails/circuit-breaker.md
    patterns/rails/bulkhead-isolation.md
    patterns/rails/load-shedding.md
    patterns/rails/graceful-degradation.md
    patterns/rails/recovery-objectives.md
    patterns/rails/resilience-testing.md
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_and_patterns
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))

    skill = manifest.fetch("skills").fetch("rails-reliability-engineering")
    assert_equal "skills/rails-reliability-engineering/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "SLO"
    assert_includes skill.fetch("triggers"), "error budget"
    assert_includes skill.fetch("triggers"), "circuit breaker"
    assert_includes skill.fetch("triggers"), "load shedding"
    assert_includes skill.fetch("triggers"), "RTO"
    assert_includes skill.fetch("triggers"), "resilience testing"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.drop(1).each do |relative|
      assert_includes rails_patterns, relative
    end
  end

  def test_router_and_agent_contract_include_reliability_guidance
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Reliability engineering and resilience"
    assert_includes routing, "rails-reliability-engineering"
    assert_includes agents, "Reliability engineering changes"
    assert_includes agents, "critical user journey"
    assert_includes agents, "RTO/RPO"
  end

  def test_skill_covers_reliability_control_plane
    skill = File.read(File.join(ROOT, "skills/rails-reliability-engineering/SKILL.md"), encoding: "UTF-8")

    [
      "Reliability objectives",
      "Error budgets and operational decisions",
      "Dependency criticality",
      "Circuit breakers",
      "Bulkheads",
      "Load shedding and admission control",
      "Graceful degradation",
      "Retry and timeout coordination",
      "Cascading failure analysis",
      "Recovery objectives",
      "Disaster recovery and reconciliation",
      "Resilience testing",
      "Observability",
      "Change and rollout safety"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Do not treat every technical metric as an SLO."
    assert_includes skill, "Retries can amplify an incident."
    assert_includes skill, "Backups are only useful when restore is tested."
  end
end
