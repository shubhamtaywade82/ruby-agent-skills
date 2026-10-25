# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsStateMachineEngineeringSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-state-machine-engineering/SKILL.md
    skills/rails-state-machine-engineering/references/transition-contracts.md
    skills/rails-state-machine-engineering/references/concurrency-and-events.md
    skills/rails-state-machine-engineering/references/side-effects-and-recovery.md
    skills/rails-state-machine-engineering/references/testing-and-migration.md
    patterns/rails/state-transition-guard.md
    patterns/testing/state-machine-testing.md
  ].freeze

  STATE_MACHINE_TRIGGERS = ["state machine", "transition table", "terminal state", "AASM",
                            "concurrent transitions", "out-of-order events"].freeze

  EVALUATION_PATHS = %w[evals/state-machine-engineering/order-state-machine-transition-contract.yml
                        evals/state-machine-engineering/transition-side-effect-recovery.yml].freeze

  SKILL_CONTRACT_SECTIONS = ["Transition table", "Guards and exit actions",
                             "Transition authorization", "Audit history",
                             "Locking strategies", "Concurrent attempts",
                             "Out-of-order events"].freeze

  RECOVERY_REFERENCE_SECTIONS = ["## Transactional effects", "## Remote effects and durable intent",
                                 "## Failure recovery", "## Reconciliation"].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_with_state_triggers
    skill = manifest.fetch("skills").fetch("rails-state-machine-engineering")

    assert_equal "skills/rails-state-machine-engineering/SKILL.md", skill.fetch("path")
    STATE_MACHINE_TRIGGERS.each { |trigger| assert_includes skill.fetch("triggers"), trigger }
  end

  def test_manifest_registers_state_patterns
    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")

    assert_includes rails_patterns, "patterns/rails/state-transition-guard.md"
    assert_includes testing_patterns, "patterns/testing/state-machine-testing.md"
  end

  def test_manifest_registers_state_evaluations
    evaluation = manifest.fetch("evaluations").fetch("state-machine-engineering")

    assert_equal EVALUATION_PATHS, evaluation.fetch("paths")
  end

  def test_router_routes_state_machines
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")

    assert_includes routing, "Domain state machines"
    assert_includes routing, "rails-state-machine-engineering"
    assert_includes routing, "AASM declaration is one implementation choice, not the contract"
  end

  def test_order_routing_case_routes_to_state_machine_skill
    entry = routing_case("order-state-machine-not-aasm-trivia")

    assert_equal ["rails-state-machine-engineering"], entry.fetch("primary_skills")
  end

  def test_webhook_routing_case_routes_to_state_machine_skill
    entry = routing_case("webhook-transition-out-of-order")

    assert_equal ["rails-state-machine-engineering"], entry.fetch("primary_skills")
  end

  def test_skill_covers_state_contract_sections
    skill = File.read(File.join(ROOT, "skills/rails-state-machine-engineering/SKILL.md"),
                      encoding: "UTF-8")

    SKILL_CONTRACT_SECTIONS.each { |section| assert_includes skill, section }
    assert_includes skill, "Never write the state column outside the transition entry point."
    assert_includes skill, "Domain state machine changes"
  end

  def test_recovery_reference_covers_side_effect_contract
    reference = File.read(
      File.join(ROOT,
                "skills/rails-state-machine-engineering/references/side-effects-and-recovery.md"),
      encoding: "UTF-8"
    )

    RECOVERY_REFERENCE_SECTIONS.each { |section| assert_includes reference, section }
    assert_includes reference, "intent before effect"
  end

  def test_patterns_declare_state_contract
    guard = File.read(File.join(ROOT, "patterns/rails/state-transition-guard.md"),
                      encoding: "UTF-8")
    testing = File.read(File.join(ROOT, "patterns/testing/state-machine-testing.md"),
                        encoding: "UTF-8")

    assert_includes guard, "## Failure modes"
    assert_includes testing, "## Failure modes"
  end

  def test_evaluations_declare_state_machine_contract
    EVALUATION_PATHS.each do |relative|
      data = YAML.safe_load(File.read(File.join(ROOT, relative), encoding: "UTF-8"))
      checks = Array(data.fetch("checks"))

      assert_equal "rails-state-machine-engineering", Array(data.fetch("skills")).first
      assert_includes checks, "functional"
      assert_includes checks, "tests"
    end
  end

  private

  def manifest
    @manifest ||= YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"),
                                           encoding: "UTF-8"))
  end

  def routing_case(id)
    cases = YAML.safe_load(
      File.read(File.join(ROOT, "router", "ROUTING_CASES.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    ).fetch("cases")
    cases.find { |entry| entry["id"] == id } || flunk("missing routing case #{id}")
  end
end
