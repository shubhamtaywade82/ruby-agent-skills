# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsApiIntegrationSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-api-integration/SKILL.md
    patterns/rails/api-contract-versioning.md
    patterns/ruby-design/resilient-http-client.md
    patterns/rails/webhook-ingestion.md
    patterns/rails/idempotent-request.md
    evals/ruby-workshop/external-api-client.yml
    evals/ruby-workshop/rails-rest-contract.yml
    evals/ruby-workshop/rails-authentication-boundary.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_and_patterns
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))

    skill = manifest.fetch("skills").fetch("rails-api-integration")
    assert_equal "skills/rails-api-integration/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "API contract"
    assert_includes skill.fetch("triggers"), "webhook"
    assert_includes skill.fetch("triggers"), "idempotency key"

    assert_includes manifest.fetch("patterns").fetch("rails").fetch("paths"),
                    "patterns/rails/api-contract-versioning.md"
    assert_includes manifest.fetch("patterns").fetch("rails").fetch("paths"),
                    "patterns/rails/webhook-ingestion.md"
    assert_includes manifest.fetch("patterns").fetch("rails").fetch("paths"),
                    "patterns/rails/idempotent-request.md"
    assert_includes manifest.fetch("patterns").fetch("ruby-design").fetch("paths"),
                    "patterns/ruby-design/resilient-http-client.md"
  end

  def test_api_evaluations_activate_skill
    %w[external-api-client.yml rails-rest-contract.yml rails-authentication-boundary.yml].each do |filename|
      evaluation = YAML.safe_load(
        File.read(File.join(ROOT, "evals/ruby-workshop", filename), encoding: "UTF-8")
      )
      assert_includes evaluation.fetch("skills"), "rails-api-integration"
    end
  end

  def test_routing_contains_integration_composition
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")
    assert_includes routing, "Rails API and integration architecture"
    assert_includes routing, "rails-api-integration"
  end
end
