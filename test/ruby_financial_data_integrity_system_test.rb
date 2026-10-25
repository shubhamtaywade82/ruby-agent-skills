# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RubyFinancialDataIntegritySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/ruby-financial-data-integrity/SKILL.md
    skills/ruby-financial-data-integrity/references/numeric-representation.md
    skills/ruby-financial-data-integrity/references/ledger-and-balances.md
    skills/ruby-financial-data-integrity/references/fees-quantities-and-pnl.md
    skills/ruby-financial-data-integrity/references/reconciliation-and-testing.md
  ].freeze

  FINANCIAL_TRIGGERS = ["BigDecimal", "decimal precision", "rounding mode", "double-entry",
                        "posting idempotency", "PnL"].freeze

  EVALUATION_PATHS = %w[
    evals/financial-data-integrity/money-representation-and-rounding-contract.yml
    evals/financial-data-integrity/double-entry-posting-invariant-contract.yml
  ].freeze

  SKILL_INVARIANTS = [
    "Never use `Float` for money or for any value that must survive arithmetic unchanged.",
    "Never mutate a balance outside a balancing journal transaction.",
    "Never post a business event twice"
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_and_triggers
    skill = manifest.fetch("skills").fetch("ruby-financial-data-integrity")

    assert_equal "skills/ruby-financial-data-integrity/SKILL.md", skill.fetch("path")
    assert_equal "ruby", skill.fetch("family")
    FINANCIAL_TRIGGERS.each { |trigger| assert_includes skill.fetch("triggers"), trigger }
  end

  def test_manifest_registers_financial_evaluations
    evaluation = manifest.fetch("evaluations").fetch("financial-data-integrity")

    assert_equal EVALUATION_PATHS, evaluation.fetch("paths")
  end

  def test_router_routes_financial_integrity
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")

    assert_includes routing, "Financial data integrity"
    assert_includes routing, "ruby-financial-data-integrity"
    assert_includes routing, "balances moved only through balancing journal entries"
  end

  def test_fee_routing_case_routes_to_financial_integrity
    entry = routing_case("cents-off-fee-calculation")

    assert_equal ["ruby-financial-data-integrity"], entry.fetch("primary_skills")
  end

  def test_ledger_replay_routing_case_routes_to_financial_integrity
    entry = routing_case("ledger-idempotent-replay")

    assert_equal ["ruby-financial-data-integrity"], entry.fetch("primary_skills")
  end

  def test_skill_states_financial_invariants
    skill = File.read(File.join(ROOT, "skills/ruby-financial-data-integrity/SKILL.md"),
                      encoding: "UTF-8")

    SKILL_INVARIANTS.each { |invariant| assert_includes skill, invariant }
    assert_includes skill, "Financial data integrity changes"
  end

  def test_references_cover_representation_and_ledger_contracts
    representation = read_reference("numeric-representation.md")

    assert_includes representation, "## Parsing boundaries"
    assert_includes representation, "## Rounding decisions"
  end

  def test_ledger_reference_covers_posting_contract
    ledger = read_reference("ledger-and-balances.md")

    assert_includes ledger, "## Double-entry invariants"
    assert_includes ledger, "## Posting transactions"
    assert_includes ledger, "## Atomic balance updates"
  end

  def test_pnl_and_reconciliation_references_cover_contracts
    pnl = read_reference("fees-quantities-and-pnl.md")
    recon = read_reference("reconciliation-and-testing.md")

    assert_includes pnl, "## Fee arithmetic"
    assert_includes pnl, "## PnL and weighted averages"
    assert_includes recon, "## External reconciliation"
  end

  def test_evaluations_declare_financial_contract
    EVALUATION_PATHS.each do |relative|
      data = YAML.safe_load(File.read(File.join(ROOT, relative), encoding: "UTF-8"))
      checks = Array(data.fetch("checks"))

      assert_equal "ruby-financial-data-integrity", Array(data.fetch("skills")).first
      assert_includes checks, "functional"
      assert_includes checks, "tests"
    end
  end

  private

  def read_reference(name)
    File.read(File.join(ROOT, "skills", "ruby-financial-data-integrity", "references", name),
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
