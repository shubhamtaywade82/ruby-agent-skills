# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsReleaseEngineeringSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-release-engineering/SKILL.md
    patterns/rails/release-risk-classification.md
    patterns/rails/artifact-provenance.md
    patterns/rails/deployment-gate.md
    patterns/rails/progressive-delivery.md
    patterns/rails/environment-parity.md
    patterns/rails/rollback-rollforward.md
    patterns/rails/release-health-verification.md
    patterns/rails/release-evidence.md
  ].freeze

  RUNTIME_EVALS = %w[
    zero-downtime-release.yml
    migration-gate.yml
    config-contract.yml
    graceful-shutdown.yml
    puma-capacity.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_and_patterns
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-release-engineering")

    assert_equal "skills/rails-release-engineering/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "release readiness"
    assert_includes skill.fetch("triggers"), "artifact provenance"
    assert_includes skill.fetch("triggers"), "deployment gate"
    assert_includes skill.fetch("triggers"), "progressive delivery"
    assert_includes skill.fetch("triggers"), "rollback"
    assert_includes skill.fetch("triggers"), "release health"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.drop(1).each { |relative| assert_includes rails_patterns, relative }
  end

  def test_routing_and_agent_contract_include_release_engineering
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Release engineering and release readiness"
    assert_includes routing, "rails-release-engineering"
    assert_includes routing, "progressive-delivery"
    assert_includes agents, "Rails release engineering changes"
    assert_includes agents, "immutable source/artifact identity"
    assert_includes agents, "rollback or roll-forward"
    assert_includes agents, "user-impact"
  end

  def test_runtime_evaluations_activate_release_engineering
    RUNTIME_EVALS.each do |filename|
      evaluation = YAML.safe_load(
        File.read(File.join(ROOT, "evals/runtime", filename), encoding: "UTF-8")
      )
      assert_includes evaluation.fetch("skills"), "rails-release-engineering"
    end
  end

  def test_skill_covers_release_lifecycle
    skill = File.read(
      File.join(ROOT, "skills/rails-release-engineering/SKILL.md"),
      encoding: "UTF-8"
    )

    [
      "Change risk classification",
      "Reproducible artifacts",
      "Pre-release verification",
      "Deployment gates",
      "Progressive delivery",
      "Environment parity",
      "Migration and worker compatibility",
      "Rollback versus roll-forward",
      "Release health verification",
      "Release evidence and audit trail",
      "Failed release handling"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Do not treat a successful local build as evidence that the production artifact is identical."
    assert_includes skill, "Never assume application rollback can reverse an irreversible database change."
    assert_includes skill, "A healthy process with degraded user outcomes is not a successful release."
  end
end
