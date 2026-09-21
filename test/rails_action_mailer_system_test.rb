# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsActionMailerSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-action-mailer/SKILL.md
    patterns/rails/mailer-contract.md
    patterns/rails/mailer-delivery-semantics.md
    patterns/rails/mailer-provider-boundary.md
    patterns/rails/mailer-security-boundary.md
    patterns/rails/mailer-observability.md
    patterns/rails/mailer-testing.md
    evals/rails/action-mailer-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-action-mailer")

    assert_equal "skills/rails-action-mailer/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "Action Mailer"
    assert_includes skill.fetch("triggers"), "deliver_later"
    assert_includes skill.fetch("triggers"), "email security"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[mailer-contract mailer-delivery-semantics mailer-provider-boundary mailer-security-boundary mailer-observability].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/rails/mailer-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-action-mailer").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/action-mailer-contract.yml"
  end

  def test_router_and_agent_contract_include_mailer_guidance
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Action Mailer"
    assert_includes routing, "rails-action-mailer"
    assert_includes routing, "mailer-delivery-semantics"
    assert_includes agents, "Rails Action Mailer changes"
    assert_includes agents, "deliver_now versus deliver_later"
    assert_includes agents, "provider"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/action-mailer-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-action-mailer"
    assert_includes evaluation.fetch("skills"), "rails-active-job"
    assert_includes evaluation.fetch("patterns"), "mailer-contract"
    assert_includes evaluation.fetch("patterns"), "mailer-delivery-semantics"
    assert_includes evaluation.fetch("patterns"), "mailer-security-boundary"
  end

  def test_skill_covers_mailer_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-action-mailer/SKILL.md"), encoding: "UTF-8")

    [
      "Mailer boundary",
      "Recipient and authorization semantics",
      "Delivery mode",
      "Transaction boundary",
      "Idempotency and duplicate delivery",
      "Message content contract",
      "Attachments",
      "Provider boundary",
      "Configuration and secrets",
      "Previews and development safety",
      "Security and privacy",
      "Observability",
      "Testing"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Do not use synchronous delivery from request paths merely because it is simpler."
    assert_includes skill, "Do not assume a failed SMTP/API call means the provider definitely did not send."
    assert_includes skill, "Never print SMTP credentials"
  end
end
