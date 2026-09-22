# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsIncidentEngineeringSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-incident-engineering/SKILL.md
    patterns/rails/incident-triage.md
    patterns/rails/operational-runbook.md
    patterns/rails/alert-actionability.md
    patterns/rails/diagnostic-context.md
    patterns/rails/incident-timeline.md
    patterns/rails/safe-production-debugging.md
    patterns/rails/recovery-verification.md
    patterns/rails/post-incident-review.md
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_and_patterns
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-incident-engineering")

    assert_equal "skills/rails-incident-engineering/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "production incident"
    assert_includes skill.fetch("triggers"), "operational runbook"
    assert_includes skill.fetch("triggers"), "safe production debugging"
    assert_includes skill.fetch("triggers"), "post-incident review"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.drop(1).each { |relative| assert_includes rails_patterns, relative }
  end

  def test_router_and_agent_contract_include_incident_guidance
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails incident engineering"
    assert_includes routing, "rails-incident-engineering"
    assert_includes agents, "Rails incident engineering changes"
    assert_includes agents, "reversible"
    assert_includes agents, "recovery"
  end

  def test_existing_observability_evaluations_activate_incident_skill
    %w[error-boundary.yml request-correlation.yml instrumentation-event.yml health-semantics.yml].each do |filename|
      evaluation = YAML.safe_load(File.read(File.join(ROOT, "evals/observability", filename), encoding: "UTF-8"))
      assert_includes evaluation.fetch("skills"), "rails-incident-engineering"
    end
  end

  def test_skill_covers_incident_engineering_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-incident-engineering/SKILL.md"), encoding: "UTF-8")

    [
      "Incident lifecycle",
      "Triage procedure",
      "Alert actionability",
      "Diagnostic context",
      "Incident timeline",
      "Hypothesis-driven debugging",
      "Safe production debugging",
      "Mitigation and recovery",
      "Runbooks",
      "Security during incidents",
      "Post-incident review",
      "Incident-to-engineering feedback loop"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Do not close an incident solely because error logs stopped increasing."
    assert_includes skill, "Never execute destructive SQL"
    assert_includes skill, "Never add credentials"
  end
end
