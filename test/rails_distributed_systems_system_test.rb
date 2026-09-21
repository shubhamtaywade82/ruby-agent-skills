# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsDistributedSystemsSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-distributed-systems/SKILL.md
    patterns/rails/distributed-service-boundary.md
    patterns/rails/message-delivery-contract.md
    patterns/rails/outbox-publication.md
    patterns/rails/inbox-deduplication.md
    patterns/rails/saga-orchestration.md
    patterns/rails/distributed-lock.md
    patterns/rails/eventual-consistency.md
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_distributed_skill_and_patterns
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))

    skill = manifest.fetch("skills").fetch("rails-distributed-systems")
    assert_equal "skills/rails-distributed-systems/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "outbox"
    assert_includes skill.fetch("triggers"), "inbox"
    assert_includes skill.fetch("triggers"), "saga"
    assert_includes skill.fetch("triggers"), "distributed lock"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.drop(1).each do |relative|
      assert_includes rails_patterns, relative
    end
  end

  def test_router_and_agent_contract_include_distributed_guidance
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "rails-distributed-systems"
    assert_includes routing, "Distributed systems and service architecture"
    assert_includes agents, "Distributed systems and service architecture changes"
    assert_includes agents, "never assume exactly-once execution"
    assert_includes agents, "distributed locks"
  end

  def test_skill_covers_failure_and_recovery_contracts
    skill = File.read(File.join(ROOT, "skills/rails-distributed-systems/SKILL.md"), encoding: "UTF-8")

    %w[
      Delivery semantics
      Outbox
      Inbox and deduplication
      Consistency
      Sagas
      Distributed locks
      Ordering and replay
      Failure model
      Rollout compatibility
      Testing
    ].each do |heading|
      assert_includes skill, heading.split.map { |word| word }.join(" ")
    end

    assert_includes skill, "Do not assume exactly-once execution."
    assert_includes skill, "producer commit before publish"
    assert_includes skill, "consumer crash after side effect"
  end
end
