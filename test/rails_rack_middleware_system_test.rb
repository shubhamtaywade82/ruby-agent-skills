# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsRackMiddlewareSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-rack-middleware-engineering/SKILL.md
    patterns/rails/rack-request-response-contract.md
    patterns/rails/middleware-stack-ordering.md
    patterns/rails/custom-rack-middleware-contract.md
    patterns/rails/middleware-short-circuit-contract.md
    patterns/rails/middleware-exception-propagation.md
    patterns/rails/middleware-thread-safety.md
    patterns/rails/request-id-correlation-boundary.md
    patterns/rails/middleware-security-boundary.md
    patterns/rails/middleware-rate-limit-boundary.md
    patterns/rails/trusted-proxy-header-contract.md
    patterns/rails/middleware-testing.md
    patterns/rails/middleware-observability-boundary.md
    evals/rails/rack-middleware-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each { |relative| assert File.file?(File.join(ROOT, relative)), "missing #{relative}" }
  end

  def test_manifest_registers_rack_skill_and_patterns
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-rack-middleware-engineering")
    assert_equal "skills/rails-rack-middleware-engineering/SKILL.md", skill.fetch("path")
    %w[Rack rack middleware config.middleware config.ru bin/rails middleware call(env) short-circuit request ID trusted proxy].each do |trigger|
      assert_includes skill.fetch("triggers"), trigger
    end
    rails = manifest.fetch("patterns").fetch("rails").fetch("paths")
    REQUIRED_PATHS.grep(%r{^patterns/rails/}).each { |p| assert_includes rails, p }
    testing = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing, "patterns/rails/middleware-testing.md"
    assert_includes manifest.fetch("evaluations").fetch("rails-rack-middleware-engineering").fetch("paths"),
                    "evals/rails/rack-middleware-contract.yml"
  end

  def test_router_and_agents_contract
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")
    assert_includes routing, "Rails Rack/Middleware engineering"
    assert_includes routing, "rails-rack-middleware-engineering"
    assert_includes agents, "Rails Rack/middleware changes"
    assert_includes agents, "middleware ordering"
    assert_includes agents, "thread"
  end

  def test_evaluation_contract
    evaluation = YAML.safe_load(File.read(File.join(ROOT, "evals/rails/rack-middleware-contract.yml"), encoding: "UTF-8"))
    assert_includes evaluation.fetch("skills"), "rails-rack-middleware-engineering"
    assert_includes evaluation.fetch("patterns"), "middleware-stack-ordering"
    assert_includes evaluation.fetch("patterns"), "middleware-testing"
    assert_equal "scope_control", evaluation.fetch("checks").last
  end

  def test_skill_covers_boundary
    skill = File.read(File.join(ROOT, "skills/rails-rack-middleware-engineering/SKILL.md"), encoding: "UTF-8")
    [
      "Core contract", "Stack ordering", "Custom middleware design", "Short-circuiting",
      "Exceptions and failure propagation", "Request context and observability",
      "Security boundaries", "Concurrency and lifecycle", "Testing strategy"
    ].each { |section| assert_includes skill, section }
    assert_includes skill, "Do not use middleware to compensate for a missing application-layer abstraction"
  end
end
