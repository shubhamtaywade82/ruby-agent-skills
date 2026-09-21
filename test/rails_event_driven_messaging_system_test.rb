# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsEventDrivenMessagingSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-event-driven-messaging/SKILL.md
    patterns/rails/event-envelope.md
    patterns/rails/event-schema-evolution.md
    patterns/rails/consumer-group-partitioning.md
    patterns/rails/dead-letter-replay.md
    patterns/rails/message-observability.md
    patterns/rails/broker-capacity.md
    patterns/rails/message-handler-boundary.md
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_and_patterns
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))

    skill = manifest.fetch("skills").fetch("rails-event-driven-messaging")
    assert_equal "skills/rails-event-driven-messaging/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "event-driven architecture"
    assert_includes skill.fetch("triggers"), "consumer group"
    assert_includes skill.fetch("triggers"), "dead-letter queue"
    assert_includes skill.fetch("triggers"), "replay"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.drop(1).each do |relative|
      assert_includes rails_patterns, relative
    end
  end

  def test_router_and_agent_contract_include_messaging_guidance
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Event-driven messaging architecture"
    assert_includes routing, "rails-event-driven-messaging"
    assert_includes agents, "Event-driven messaging changes"
    assert_includes agents, "message identity"
    assert_includes agents, "dead-letter"
  end

  def test_skill_covers_operational_message_contract
    skill = File.read(File.join(ROOT, "skills/rails-event-driven-messaging/SKILL.md"), encoding: "UTF-8")

    [
      "Envelope contract",
      "Schema evolution",
      "Topic, queue, routing-key, and partition design",
      "Consumer groups and parallelism",
      "Acknowledgement",
      "Retry policy",
      "Dead-letter queues and poison messages",
      "Replay and backfill",
      "Message observability",
      "Capacity and backpressure",
      "Rolling deployments"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Do not assume Kafka-style semantics"
    assert_includes skill, "Do not retry a poison message forever"
    assert_includes skill, "A replay should not accidentally trigger user-visible effects twice."
  end
end
