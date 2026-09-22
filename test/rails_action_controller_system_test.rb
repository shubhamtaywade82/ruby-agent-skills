# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RailsActionControllerSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/rails-action-controller/SKILL.md
    patterns/rails/action-controller-request-boundary.md
    patterns/rails/strong-parameters-contract.md
    patterns/rails/controller-response-contract.md
    patterns/rails/controller-session-cookie-boundary.md
    patterns/rails/action-controller-callback-contract.md
    patterns/rails/controller-content-negotiation.md
    patterns/rails/conditional-response-cache.md
    patterns/rails/controller-streaming-download.md
    patterns/rails/controller-exception-boundary.md
    patterns/rails/action-controller-testing.md
    evals/rails/action-controller-contract.yml
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_patterns_and_evaluation
    manifest = YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"))
    skill = manifest.fetch("skills").fetch("rails-action-controller")

    assert_equal "skills/rails-action-controller/SKILL.md", skill.fetch("path")
    assert_includes skill.fetch("triggers"), "Action Controller"
    assert_includes skill.fetch("triggers"), "strong parameters"
    assert_includes skill.fetch("triggers"), "content negotiation"
    assert_includes skill.fetch("triggers"), "rescue_from"
    assert_includes skill.fetch("triggers"), "ETag"
    assert_includes skill.fetch("triggers"), "streaming"

    rails_patterns = manifest.fetch("patterns").fetch("rails").fetch("paths")
    %w[
      action-controller-request-boundary
      strong-parameters-contract
      controller-response-contract
      controller-session-cookie-boundary
      action-controller-callback-contract
      controller-content-negotiation
      conditional-response-cache
      controller-streaming-download
      controller-exception-boundary
    ].each do |name|
      assert_includes rails_patterns, "patterns/rails/#{name}.md"
    end

    testing_patterns = manifest.fetch("patterns").fetch("testing").fetch("paths")
    assert_includes testing_patterns, "patterns/rails/action-controller-testing.md"

    evaluation_paths = manifest.fetch("evaluations").fetch("rails-action-controller").fetch("paths")
    assert_includes evaluation_paths, "evals/rails/action-controller-contract.yml"
  end

  def test_router_and_agent_contract_include_action_controller
    routing = File.read(File.join(ROOT, "router/ROUTING.md"), encoding: "UTF-8")
    agents = File.read(File.join(ROOT, "AGENTS.md"), encoding: "UTF-8")

    assert_includes routing, "Rails Action Controller"
    assert_includes routing, "rails-action-controller"
    assert_includes routing, "strong-parameters-contract"
    assert_includes agents, "Rails Action Controller changes"
    assert_includes agents, "params.expect"
    assert_includes agents, "controller callback"
    assert_includes agents, "conditional response"
    assert_includes agents, "streaming"
    assert_includes agents, "rescue_from"
  end

  def test_evaluation_activates_expected_skills_and_patterns
    evaluation = YAML.safe_load(
      File.read(File.join(ROOT, "evals/rails/action-controller-contract.yml"), encoding: "UTF-8")
    )

    assert_includes evaluation.fetch("skills"), "rails-action-controller"
    assert_includes evaluation.fetch("skills"), "rails-security"
    assert_includes evaluation.fetch("patterns"), "strong-parameters-contract"
    assert_includes evaluation.fetch("patterns"), "conditional-response-cache"
    assert_includes evaluation.fetch("patterns"), "controller-streaming-download"
    assert_includes evaluation.fetch("patterns"), "action-controller-testing"
  end

  def test_skill_covers_action_controller_lifecycle
    skill = File.read(File.join(ROOT, "skills/rails-action-controller/SKILL.md"), encoding: "UTF-8")

    [
      "Request boundary",
      "Parameters and strong parameters",
      "Request object semantics",
      "Response contract",
      "Render and redirect semantics",
      "Sessions, cookies, and flash",
      "Controller callbacks",
      "Content negotiation",
      "Conditional GET and HTTP cache validators",
      "Streaming and downloads",
      "Exception handling",
      "Security and privacy",
      "Performance and capacity",
      "Testing"
    ].each { |section| assert_includes skill, section }

    assert_includes skill, "Do not use permit! merely to make an integration work"
    assert_includes skill, "Do not stream an unbounded database query"
    assert_includes skill, "Do not catch StandardError broadly"
    assert_includes skill, "Do not enable cross-host redirects for untrusted input"
    assert_includes skill, "validation success as authorization"
  end
end
