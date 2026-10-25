# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsExternalStreamIngestionSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-external-stream-ingestion/SKILL.md
    skills/rails-external-stream-ingestion/references/connection-lifecycle.md
    skills/rails-external-stream-ingestion/references/buffering-and-ordering.md
    skills/rails-external-stream-ingestion/references/freshness-and-recovery.md
    skills/rails-external-stream-ingestion/references/state-and-testing.md
  ].freeze

  FEED_TRIGGERS = [
    "external stream",
    "market data feed",
    "feed reconnection",
    "feed backpressure",
    "stale feed"
  ].freeze

  EVALUATION_PATHS = %w[
    evals/external-stream-ingestion/reconnect-resubscription-contract.yml
    evals/external-stream-ingestion/feed-freshness-failure-semantics.yml
  ].freeze

  SKILL_CONTRACT_SECTIONS = %w[
    Connection ownership Bounded buffering Freshness contract Stale-feed detection
    Missing events and gaps Event time versus processing time Failure semantics
  ].freeze

  STATE_AND_TESTING_SECTIONS = %w[
    ## Subscription registry ## Thread-safe feed state ## Cache consistency
    ## Deterministic fake-client tests
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_with_feed_triggers
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-external-stream-ingestion")

    assert_equal "skills/rails-external-stream-ingestion/SKILL.md", skill.fetch("path")
    FEED_TRIGGERS.each do |trigger|
      assert_includes skill.fetch("triggers"), trigger
    end
  end

  def test_manifest_registers_evaluations
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    paths = manifest.fetch("evaluations").fetch("external-stream-ingestion").fetch("paths")

    assert_equal EVALUATION_PATHS, paths
  end

  def test_router_routes_feed_ingestion_away_from_action_cable
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")

    assert_includes routing, "External stream ingestion"
    assert_includes routing, "rails-external-stream-ingestion"
    assert_includes routing, "External stream ingestion owns the consuming side"
  end

  def test_routing_case_routes_feed_client_to_ingestion_skill
    entry = routing_case("external-feed-client-not-action-cable")

    assert_equal "rails-external-stream-ingestion", entry.fetch("primary_skills").first
    assert_includes Array(entry.fetch("secondary_skills")), "rails-action-cable"
  end

  def test_routing_case_routes_stale_feed_guard_to_ingestion_skill
    entry = routing_case("stale-feed-order-guard")

    assert_equal "rails-external-stream-ingestion", entry.fetch("primary_skills").first
    assert_includes Array(entry.fetch("secondary_skills")), "rails-reliability-engineering"
  end

  def test_skill_covers_stream_contract_sections
    skill = File.read(File.join(ROOT, "skills/rails-external-stream-ingestion/SKILL.md"),
                      encoding: "UTF-8")

    SKILL_CONTRACT_SECTIONS.each { |section| assert_includes skill, section }
  end

  def test_state_and_testing_reference_covers_subscription_and_testing_contract
    reference = read_skill_reference("state-and-testing.md")

    STATE_AND_TESTING_SECTIONS.each { |section| assert_includes reference, section }
  end

  def test_skill_states_stream_failure_invariants
    skill = File.read(File.join(ROOT, "skills/rails-external-stream-ingestion/SKILL.md"),
                      encoding: "UTF-8")

    assert_includes skill, "Never let a feed callback block"
    assert_includes skill, "Do not treat a live connection as proof of fresh data"
    assert_includes skill, "External stream ingestion changes"
  end

  def test_evaluations_declare_feed_contract
    EVALUATION_PATHS.each do |relative|
      data = YAML.safe_load(File.read(File.join(ROOT, relative), encoding: "UTF-8"))

      assert_equal "rails-external-stream-ingestion", Array(data.fetch("skills")).first
      assert_includes Array(data.fetch("checks")), "functional"
      assert_includes Array(data.fetch("checks")), "tests"
    end
  end

  private

  def read_skill_reference(name)
    File.read(File.join(ROOT, "skills", "rails-external-stream-ingestion", "references", name),
              encoding: "UTF-8")
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
