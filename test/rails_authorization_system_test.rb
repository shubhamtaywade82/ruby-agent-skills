# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsAuthorizationSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-authorization/SKILL.md
    patterns/rails/authorization-mechanism-boundary.md
    patterns/rails/policy-object-boundary.md
    patterns/rails/authorized-scope-boundary.md
    patterns/rails/tenant-isolation-authorization.md
    patterns/rails/role-capability-boundary.md
    patterns/rails/contextual-authorization.md
    patterns/rails/authorization-service-boundary.md
    patterns/rails/background-authorization-boundary.md
    patterns/rails/api-authorization-boundary.md
    patterns/rails/action-cable-authorization-boundary.md
    patterns/rails/authorization-cache-identity.md
    patterns/rails/authorization-audit-contract.md
    patterns/testing/authorization-testing.md
    evals/rails/authorization-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_authorization
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-authorization")

    assert_equal "skills/rails-authorization/SKILL.md", skill.fetch("path")
    %w[
      authorization
      policy
      Pundit
      CanCanCan
      tenant isolation
      object-level authorization
      IDOR
      authorized scope
      role
      permission
    ].each { |trigger| assert_includes skill.fetch("triggers"), trigger }

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      authorization-mechanism-boundary
      policy-object-boundary
      authorized-scope-boundary
      tenant-isolation-authorization
      role-capability-boundary
      contextual-authorization
      authorization-service-boundary
      background-authorization-boundary
      api-authorization-boundary
      action-cable-authorization-boundary
      authorization-cache-identity
      authorization-audit-contract
    ].each { |name| assert_includes rails_patterns, "patterns/rails/#{name}.md" }

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/testing/authorization-testing.md"

    eval_paths = manifest.fetch("evaluations").fetch("rails-authorization").fetch("paths")
    assert_includes eval_paths, "evals/rails/authorization-contract.yml"
  end

  def test_router_and_agent_contract_include_authorization
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Authorization engineering"
    assert_includes routing, "rails-authorization"
    assert_includes routing, "authorized-scope-boundary"

    assert_includes agents, "Rails authorization changes"
    assert_includes agents, "authentication and authorization remain separate"
    assert_includes agents, "tenant isolation"
    assert_includes agents, "cross-tenant"
  end

  def test_evaluation_activates_expected_contracts
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/authorization-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-authorization"
    assert_includes evaluation.fetch("skills"), "rails-security-engineering"
    assert_includes evaluation.fetch("patterns"), "authorized-scope-boundary"
    assert_includes evaluation.fetch("patterns"), "tenant-isolation-authorization"
    assert_includes evaluation.fetch("patterns"), "background-authorization-boundary"
    assert_includes evaluation.fetch("patterns"), "authorization-testing"
  end

  def test_skill_covers_authorization_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-authorization/SKILL.md"), encoding: "UTF-8")

    [
      "Authorization model",
      "Policy boundary",
      "Object-level authorization",
      "Collection authorization",
      "Tenant isolation",
      "Roles, permissions, and contextual authorization",
      "State-dependent authorization",
      "Controllers and APIs",
      "Service objects and domain workflows",
      "Background jobs",
      "Action Cable and realtime",
      "Webhooks and service identities",
      "Authorization versus validation and strong parameters",
      "Fail closed",
      "TOCTOU and transactional boundaries",
      "Caching",
      "Audit and observability",
      "Testing strategy"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Authentication establishes identity; authorization establishes permission."
    assert_includes skill, "Do not use frontend route guards as authorization."
    assert_includes skill, "Never trust a client-supplied tenant ID as proof of tenancy."
    assert_includes skill, "re-authorize the operation"
  end
end
