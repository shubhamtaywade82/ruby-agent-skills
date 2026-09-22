# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsActionCableSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-action-cable/SKILL.md
    patterns/rails/action-cable-connection-auth.md
    patterns/rails/action-cable-channel-authorization.md
    patterns/rails/action-cable-stream-contract.md
    patterns/rails/action-cable-broadcast-contract.md
    patterns/rails/action-cable-reconciliation.md
    patterns/rails/action-cable-capacity.md
    patterns/rails/action-cable-failure-boundary.md
    patterns/rails/action-cable-testing.md
    evals/rails/action-cable-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-action-cable")

    assert_equal "skills/rails-action-cable/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "Action Cable"
    assert_includes skill.fetch("triggers"), "WebSocket"
    assert_includes skill.fetch("triggers"), "channel authorization"
    assert_includes skill.fetch("triggers"), "reconnect"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[action-cable-connection-auth action-cable-channel-authorization action-cable-stream-contract action-cable-broadcast-contract action-cable-reconciliation action-cable-capacity action-cable-failure-boundary].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/rails/action-cable-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-action-cable").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/action-cable-contract.yml"
  end

  def test_router_and_agent_contract_include_action_cable
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Action Cable"
    assert_includes routing, "rails-action-cable"
    assert_includes routing, "action-cable-reconciliation"
    assert_includes agents, "Rails Action Cable changes"
    assert_includes agents, "authentication separate from per-channel/resource authorization"
    assert_includes agents, "Action Cable as durable messaging"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/action-cable-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-action-cable"
    assert_includes evaluation.fetch("skills"), "rails-security"
    assert_includes evaluation.fetch("patterns"), "action-cable-channel-authorization"
    assert_includes evaluation.fetch("patterns"), "action-cable-broadcast-contract"
    assert_includes evaluation.fetch("patterns"), "action-cable-reconciliation"
  end

  def test_skill_covers_action_cable_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-action-cable/SKILL.md"), encoding: "UTF-8")

    [
      "Connection authentication",
      "Connection lifecycle",
      "Channel boundary",
      "Subscription authorization",
      "Channel parameters",
      "Stream naming",
      "Broadcast contract",
      "Realtime is not durable delivery",
      "Client reconnect and resubscribe",
      "Client actions",
      "Broadcasting after state changes",
      "Broadcast fan-out",
      "Backpressure and overload",
      "Realtime capacity model",
      "Redis and adapter topology",
      "Failure behavior",
      "Security and privacy",
      "Operational lifecycle",
      "Observability",
      "Testing"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Authentication proves identity; it does not grant subscription access."
    assert_includes skill, "Do not use Action Cable as a durable queue."
    assert_includes skill, "Never let a client select a broadcast namespace that it could not otherwise authorize."
    assert_includes skill, "Do not claim a single broadcast after reconnect repairs all missed state."
  end
end
