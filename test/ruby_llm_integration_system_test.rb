# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RubyLlmIntegrationSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  REQUIRED_PATHS = %w[
    skills/ruby-llm-integration/SKILL.md
    skills/ruby-llm-integration/references/provider-adapters-and-budgets.md
    skills/ruby-llm-integration/references/output-validation-and-tools.md
    skills/ruby-llm-integration/references/operations-and-degradation.md
  ].freeze

  LLM_TRIGGERS = ["LLM integration", "RubyLLM", "Ollama integration", "structured output",
                  "tool calls", "prompt injection", "token budget"].freeze

  EVALUATION_PATHS = %w[
    evals/llm-integration/structured-output-tool-authorization-contract.yml
    evals/llm-integration/llm-degradation-and-deterministic-path-contract.yml
  ].freeze

  SKILL_INVARIANTS = [
    "Never place model output inside the prompt as instructions",
    "Never execute a tool call because the model requested it",
    "Never let an LLM call bypass, soften, or substitute a deterministic guard",
    "Never call a provider without a timeout and a budget."
  ].freeze

  def test_required_artifacts_exist
    REQUIRED_PATHS.each do |relative|
      assert File.file?(File.join(ROOT, relative)), "missing #{relative}"
    end
  end

  def test_manifest_registers_skill_and_triggers
    skill = manifest.fetch("skills").fetch("ruby-llm-integration")

    assert_equal "skills/ruby-llm-integration/SKILL.md", skill.fetch("path")
    assert_equal "ruby", skill.fetch("family")
    LLM_TRIGGERS.each { |trigger| assert_includes skill.fetch("triggers"), trigger }
  end

  def test_manifest_registers_llm_evaluations
    evaluation = manifest.fetch("evaluations").fetch("llm-integration")

    assert_equal EVALUATION_PATHS, evaluation.fetch("paths")
  end

  def test_router_routes_llm_integration
    routing = File.read(File.join(ROOT, "router", "ROUTING.md"), encoding: "UTF-8")

    assert_includes routing, "Ruby LLM integration"
    assert_includes routing, "ruby-llm-integration"
    assert_includes routing, "The model proposes; the application disposes"
  end

  def test_guard_routing_case_routes_to_llm_integration
    entry = routing_case("llm-output-before-guard-not-instead")

    assert_equal ["ruby-llm-integration"], entry.fetch("primary_skills")
  end

  def test_degradation_routing_case_routes_to_llm_integration
    entry = routing_case("llm-provider-unavailable-degrades")

    assert_equal ["ruby-llm-integration"], entry.fetch("primary_skills")
  end

  def test_skill_states_llm_invariants
    skill = File.read(File.join(ROOT, "skills/ruby-llm-integration/SKILL.md"), encoding: "UTF-8")

    SKILL_INVARIANTS.each { |invariant| assert_includes skill, invariant }
    assert_includes skill, "Ruby LLM integration changes"
  end

  def test_adapter_reference_covers_budget_contract
    reference = read_reference("provider-adapters-and-budgets.md")

    assert_includes reference, "## The adapter boundary"
    assert_includes reference, "## Timeouts and retries"
    assert_includes reference, "## Token and cost budgets"
  end

  def test_output_reference_covers_injection_and_tools
    reference = read_reference("output-validation-and-tools.md")

    assert_includes reference, "## Structured output"
    assert_includes reference, "## Prompt-injection boundaries"
    assert_includes reference, "## Tool-call authorization"
  end

  def test_operations_reference_covers_degradation
    reference = read_reference("operations-and-degradation.md")

    assert_includes reference, "## LLM observability"
    assert_includes reference, "## Graceful degradation"
    assert_includes reference, "## LLMs in deterministic systems"
  end

  def test_evaluations_declare_llm_contract
    EVALUATION_PATHS.each do |relative|
      data = YAML.safe_load(File.read(File.join(ROOT, relative), encoding: "UTF-8"))
      checks = Array(data.fetch("checks"))

      assert_equal "ruby-llm-integration", Array(data.fetch("skills")).first
      assert_includes checks, "functional"
      assert_includes checks, "tests"
    end
  end

  private

  def read_reference(name)
    File.read(File.join(ROOT, "skills", "ruby-llm-integration", "references", name),
              encoding: "UTF-8")
  end

  def manifest
    @manifest ||= YAML.safe_load(File.read(File.join(ROOT, "skill-manifest.yml"),
                                           encoding: "UTF-8"))
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
