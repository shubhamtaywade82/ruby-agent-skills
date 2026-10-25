# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class TradingMarketDataAndBacktestingSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/trading-market-data-and-backtesting/SKILL.md
    skills/trading-market-data-and-backtesting/references/market-data-integrity.md
    skills/trading-market-data-and-backtesting/references/indicators-and-lookahead.md
    skills/trading-market-data-and-backtesting/references/simulation-and-evaluation.md
  ].freeze

  MARKET_DATA_TRIGGERS = ["OHLCV", "candle gaps", "timeframe alignment", "session calendar",
                          "backtest", "look-ahead bias", "out-of-sample"].freeze

  EVALUATION_PATHS = %w[
    evals/market-data-and-backtesting/ohlcv-integrity-and-gaps-contract.yml
    evals/market-data-and-backtesting/backtest-lookahead-contract.yml
  ].freeze

  SKILL_INVARIANTS = [
    "Never let a backtest observe data beyond the simulated decision time.",
    "Never silently forward-fill or interpolate a gap without recording it.",
    "Never fill a simulated order at a price that required knowing the future"
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_and_triggers
    skill = manifest.fetch("skills").fetch("trading-market-data-and-backtesting")

    assert_equal "skills/trading-market-data-and-backtesting/SKILL.md", skill.fetch("path")
    assert_equal "trading", skill.fetch("family")
    MARKET_DATA_TRIGGERS.each { |trigger| assert_includes skill.fetch("triggers"), trigger }
  end

  def test_manifest_registers_market_data_evaluations
    evaluation = manifest.fetch("evaluations").fetch("market-data-and-backtesting")

    assert_equal EVALUATION_PATHS, evaluation.fetch("paths")
  end

  def test_router_routes_market_data_and_backtesting
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")

    assert_includes routing, "Market data and backtesting"
    assert_includes routing, "trading-market-data-and-backtesting"
    assert_includes routing, "measurement infrastructure"
  end

  def test_backtest_routing_case_routes_to_market_data_skill
    entry = routing_case("backtest-looks-too-good")

    assert_equal ["trading-market-data-and-backtesting"], entry.fetch("primary_skills")
  end

  def test_candle_routing_case_routes_to_market_data_skill
    entry = routing_case("candle-gaps-timezone-boundary")

    assert_equal ["trading-market-data-and-backtesting"], entry.fetch("primary_skills")
  end

  def test_skill_states_market_data_invariants
    skill = File.read(File.join(ROOT, "skills/trading-market-data-and-backtesting/SKILL.md"),
                      encoding: "UTF-8")

    SKILL_INVARIANTS.each { |invariant| assert_includes skill, invariant }
    assert_includes skill, "Market data and backtesting changes"
  end

  def test_data_reference_covers_ohlcv_and_calendars
    reference = read_reference("market-data-integrity.md")

    assert_includes reference, "## The OHLCV contract"
    assert_includes reference, "## Candle gaps"
    assert_includes reference, "## Session calendars and timezones"
  end

  def test_lookahead_reference_covers_as_of_discipline
    reference = read_reference("indicators-and-lookahead.md")

    assert_includes reference, "## Look-ahead bias"
    assert_includes reference, "## Data leakage beyond prices"
  end

  def test_simulation_reference_covers_fills_and_evaluation
    reference = read_reference("simulation-and-evaluation.md")

    assert_includes reference, "## Fill models"
    assert_includes reference, "## Deterministic replay"
    assert_includes reference, "## Out-of-sample evaluation"
  end

  def test_evaluations_declare_market_data_contract
    EVALUATION_PATHS.each do |relative|
      data = YAML.safe_load(File.read(File.join(ROOT, relative), encoding: "UTF-8"))
      checks = Array(data.fetch("checks"))

      assert_equal "trading-market-data-and-backtesting", Array(data.fetch("skills")).first
      assert_includes checks, "functional"
      assert_includes checks, "tests"
    end
  end

  private

  def read_reference(name)
    File.read(
      File.join(ROOT, "skills", "trading-market-data-and-backtesting", "references", name),
      encoding: "UTF-8"
    )
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
