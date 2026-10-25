# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class TradingExecutionSafetySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/trading-execution-safety/SKILL.md
    skills/trading-execution-safety/references/intent-and-identity.md
    skills/trading-execution-safety/references/submission-and-fills.md
    skills/trading-execution-safety/references/retries-and-reconciliation.md
    skills/trading-execution-safety/references/paper-live-and-testing.md
  ].freeze

  EXECUTION_TRIGGERS = ["order execution", "client order ID", "paper trading", "live trading",
                        "partial fill", "broker reconciliation"].freeze

  EVALUATION_PATHS = %w[
    evals/trading-execution-safety/duplicate-order-prevention-contract.yml
    evals/trading-execution-safety/uncertain-outcome-reconciliation-contract.yml
  ].freeze

  SKILL_INVARIANTS = [
    "Never submit without a durable, uniquely identified intent recorded first.",
    "Never resubmit an order whose submission outcome is unknown; reconcile instead.",
    "Never let a live submission path be reachable by default"
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_and_family
    skill = manifest.fetch("skills").fetch("trading-execution-safety")

    assert_equal "skills/trading-execution-safety/SKILL.md", skill.fetch("path")
    assert_equal "trading", skill.fetch("family")
    EXECUTION_TRIGGERS.each { |trigger| assert_includes skill.fetch("triggers"), trigger }
  end

  def test_manifest_registers_execution_evaluations
    evaluation = manifest.fetch("evaluations").fetch("trading-execution-safety")

    assert_equal EVALUATION_PATHS, evaluation.fetch("paths")
  end

  def test_router_routes_execution_safety
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")

    assert_includes routing, "Trading execution safety"
    assert_includes routing, "trading-execution-safety"
    assert_includes routing, "where a defect has direct financial consequences"
  end

  def test_timeout_routing_case_routes_to_execution_safety
    entry = routing_case("broker-timeout-not-safe-retry")

    assert_equal ["trading-execution-safety"], entry.fetch("primary_skills")
  end

  def test_live_gate_routing_case_routes_to_execution_safety
    entry = routing_case("live-trading-fails-closed")

    assert_equal ["trading-execution-safety"], entry.fetch("primary_skills")
  end

  def test_skill_states_execution_invariants
    skill = File.read(File.join(ROOT, "skills/trading-execution-safety/SKILL.md"),
                      encoding: "UTF-8")

    SKILL_INVARIANTS.each { |invariant| assert_includes skill, invariant }
    assert_includes skill, "Trading execution safety changes"
  end

  def test_references_cover_identity_and_fill_contracts
    identity = read_reference("intent-and-identity.md")

    assert_includes identity, "## Client order ID generation"
    assert_includes identity, "## Duplicate prevention at three layers"
  end

  def test_references_cover_fill_semantics
    fills = read_reference("submission-and-fills.md")

    assert_includes fills, "## Acknowledgement versus fill"
    assert_includes fills, "## Partial fills"
  end

  def test_paper_live_reference_covers_gates_and_testing
    reference = read_reference("paper-live-and-testing.md")

    assert_includes reference, "## Paper/live separation"
    assert_includes reference, "## Fail-closed gates"
    assert_includes reference, "## Execution testing"
  end

  def test_evaluations_declare_execution_contract
    EVALUATION_PATHS.each do |relative|
      data = YAML.safe_load(File.read(File.join(ROOT, relative), encoding: "UTF-8"))
      checks = Array(data.fetch("checks"))

      assert_equal "trading-execution-safety", Array(data.fetch("skills")).first
      assert_includes checks, "functional"
      assert_includes checks, "tests"
    end
  end

  private

  def read_reference(name)
    File.read(File.join(ROOT, "skills", "trading-execution-safety", "references", name),
              encoding: "UTF-8")
  end

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
