# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsRoutingSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-routing/SKILL.md
    patterns/rails/route-precedence-contract.md
    patterns/rails/nested-route-boundary.md
    patterns/rails/route-scope-namespace-contract.md
    patterns/rails/route-constraint-contract.md
    patterns/rails/route-helper-contract.md
    patterns/rails/route-concern-contract.md
    patterns/rails/direct-route-resolution.md
    patterns/rails/mounted-endpoint-boundary.md
    patterns/rails/catch-all-route-boundary.md
    patterns/testing/route-testing.md
    evals/rails/routing-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-routing")

    assert_equal "skills/rails-routing/SKILL.md", skill.fetch("path")
    %w[routes route resources nested namespace scope constraints subdomain host format polymorphic direct resolve concern catch-all mounted localized precedence].each do |trigger|
      assert_includes skill.fetch("triggers").join(" "), trigger
    end

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      route-precedence-contract
      nested-route-boundary
      route-scope-namespace-contract
      route-constraint-contract
      route-helper-contract
      route-concern-contract
      direct-route-resolution
      mounted-endpoint-boundary
      catch-all-route-boundary
    ].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    assert_includes manifest.fetch("patterns").fetch("testing").fetch("paths"), "patterns/testing/route-testing.md"
    assert_includes manifest.fetch("evaluations").fetch("rails-routing").fetch("paths"), "evals/rails/routing-contract.yml"
  end

  def test_router_and_agent_contract_include_routing
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Routing deep engineering"
    assert_includes routing, "rails-routing"
    assert_includes routing, "route-precedence-contract"
    assert_includes routing, "nested-route-boundary"

    assert_includes agents, "Rails Routing changes"
    assert_includes agents, "route precedence"
    assert_includes agents, "routing constraints"
    assert_includes agents, "URL helper contracts"
    assert_includes agents, "mounted boundaries"
  end

  def test_skill_covers_deep_routing_contract
    skill = File.read(File.join(ROOT, "skills/rails-routing/SKILL.md"), encoding: "UTF-8")

    [
      "Route precedence and shadowing",
      "Nested and shallow resources",
      "Namespaces and scopes",
      "Constraints",
      "Route helpers and URL generation",
      "Routing concerns",
      "Direct routes and resolve",
      "Rack mounts and engines",
      "API and format routing",
      "Localization and host-aware routing",
      "Route-file organization",
      "Testing and verification"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Routing answers which endpoint receives a request, not whether the actor may perform the operation."
    assert_includes skill, "first matching route wins"
    assert_includes skill, "Do not perform database writes, network calls, authorization workflows, or business transactions inside constraints."
    assert_includes skill, "assert_generates"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(File.read(File.join(ROOT, "evals/rails/routing-contract.yml"), encoding: "UTF-8"))
    assert_includes evaluation.fetch("skills"), "rails-routing"
    assert_includes evaluation.fetch("skills"), "rails-action-controller"
    assert_includes evaluation.fetch("skills"), "rails-security"
    assert_includes evaluation.fetch("patterns"), "route-precedence-contract"
    assert_includes evaluation.fetch("patterns"), "route-helper-contract"
    assert_includes evaluation.fetch("patterns"), "route-testing"
  end
end
