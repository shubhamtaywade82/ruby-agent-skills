# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsActionMailboxSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-action-mailbox/SKILL.md
    patterns/rails/action-mailbox-ingress-boundary.md
    patterns/rails/action-mailbox-routing-contract.md
    patterns/rails/action-mailbox-authenticity-security.md
    patterns/rails/action-mailbox-idempotency.md
    patterns/rails/action-mailbox-processing-lifecycle.md
    patterns/rails/action-mailbox-tenant-association.md
    patterns/rails/action-mailbox-failure-quarantine.md
    patterns/rails/action-mailbox-testing.md
    evals/rails/action-mailbox-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-action-mailbox")

    assert_equal "skills/rails-action-mailbox/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "Action Mailbox"
    assert_includes skill.fetch("triggers"), "InboundEmail"
    assert_includes skill.fetch("triggers"), "ApplicationMailbox"
    assert_includes skill.fetch("triggers"), "ingress"
    assert_includes skill.fetch("triggers"), "mailbox routing"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      action-mailbox-ingress-boundary
      action-mailbox-routing-contract
      action-mailbox-authenticity-security
      action-mailbox-idempotency
      action-mailbox-processing-lifecycle
      action-mailbox-tenant-association
      action-mailbox-failure-quarantine
    ].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/rails/action-mailbox-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-action-mailbox").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/action-mailbox-contract.yml"
  end

  def test_router_and_agent_contract_include_action_mailbox
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Action Mailbox"
    assert_includes routing, "rails-action-mailbox"
    assert_includes routing, "action-mailbox-idempotency"
    assert_includes agents, "Rails Action Mailbox changes"
    assert_includes agents, "ingress authentication"
    assert_includes agents, "From header"
    assert_includes agents, "domain idempotency"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/action-mailbox-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-action-mailbox"
    assert_includes evaluation.fetch("skills"), "rails-security"
    assert_includes evaluation.fetch("skills"), "rails-active-job"
    assert_includes evaluation.fetch("patterns"), "action-mailbox-idempotency"
    assert_includes evaluation.fetch("patterns"), "action-mailbox-tenant-association"
    assert_includes evaluation.fetch("patterns"), "action-mailbox-failure-quarantine"
  end

  def test_skill_covers_action_mailbox_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-action-mailbox/SKILL.md"), encoding: "UTF-8")

    [
      "Ingress boundary",
      "Mailbox routing",
      "Mailbox processing boundary",
      "Lifecycle and processing states",
      "Callbacks and failure semantics",
      "Authenticity and security",
      "Idempotency and duplicate delivery",
      "Tenant and resource association",
      "Attachments and Active Storage",
      "Transactions and asynchronous work",
      "Retention, privacy, and incineration",
      "Observability and operations",
      "Capacity and performance",
      "Local development and testing"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Never log full raw email bodies by default."
    assert_includes skill, "Do not assume one InboundEmail row means the business effect has happened exactly once."
    assert_includes skill, "Treat inbound email as hostile input."
    assert_includes skill, "Do not trust From, Reply-To, Return-Path, or arbitrary headers as authentication"
    assert_includes skill, "Never claim that inbound email is exactly-once"
  end
end
