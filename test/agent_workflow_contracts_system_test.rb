# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "../lib/ruby_agent_skills/fact_manifest"

class AgentWorkflowContractsSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  REFERENCES = File.join(ROOT, "skills", "agent-workflow", "references")
  SKILL_PATH = File.join(ROOT, "skills", "agent-workflow", "SKILL.md")
  FACT_GATE = File.join(REFERENCES, "fact-gate.md")
  EXECUTION_CONTROL = File.join(REFERENCES, "execution-control.md")
  VALIDATE_PATH = File.join(ROOT, "bin", "validate")
  FACT_MANIFEST = RubyAgentSkills::FactManifest

  CONTROL_SECTIONS = [
    "## 1. Destructive commands and approval boundaries",
    "## 2. Credential and network access",
    "## 3. Checkpointing and recovery",
    "## 4. Verified undo of failed multi-file changes",
    "## 5. Budgets: tokens, tool calls, runtime, and context",
    "## 6. Reproducibility and decision provenance"
  ].freeze

  def documented_example
    block = File.read(FACT_GATE, encoding: "UTF-8")[/```yaml\n(.*?)```/m, 1]
    YAML.safe_load(block.to_s, permitted_classes: [], aliases: false).fetch("facts")
  end

  def fact(id, klass, critical, **extra)
    fact = { "id" => id, "class" => klass, "task_critical" => critical }
    fact.merge(extra.transform_keys(&:to_s))
  end

  def malformed_manifests
    {
      "unknown class" => [fact("a", "observd", true, source: "x")],
      "observed without a source" => [fact("a", "observed", true)],
      "inferred without a basis" => [fact("a", "inferred", true)],
      "string task_critical" => [fact("a", "observed", "yes", source: "x")],
      "duplicate ids" => [fact("a", "observed", true, source: "x"),
                          fact("a", "observed", false, source: "y")],
      "empty list" => [],
      "non-mapping fact" => ["ruby-version"]
    }
  end

  def assert_rejected(facts, label)
    result = FACT_MANIFEST.evaluate(facts)

    assert_equal "blocked", result["status"], label
    refute_empty result["errors"], label
    assert_empty result["blocking"], label
    assert_empty result["unverified"], label
  end

  def test_documented_example_blocks_on_the_task_critical_inference
    result = FACT_MANIFEST.evaluate(documented_example)

    assert_equal "blocked", result["status"]
    assert_equal ["queue-adapter"], result["blocking"]
    assert_equal ["replica-topology"], result["unverified"]
  end

  def test_fully_evidenced_manifest_proceeds
    facts = [fact("ruby", "observed", true, source: ".ruby-version"),
             fact("rails", "derived", true, source: "Gemfile.lock; major version rule")]

    result = FACT_MANIFEST.evaluate(facts)

    assert_equal "proceed", result["status"]
    assert_empty result["blocking"]
  end

  def test_non_critical_unknowns_do_not_block_but_are_reported
    facts = [fact("ruby", "observed", true, source: ".ruby-version"),
             fact("replica", "unknown", false)]

    result = FACT_MANIFEST.evaluate(facts)

    assert_equal "proceed", result["status"]
    assert_equal ["replica"], result["unverified"]
  end

  def test_task_critical_unknown_blocks
    result = FACT_MANIFEST.evaluate([fact("auth", "unknown", true)])

    assert_equal "blocked", result["status"]
    assert_equal ["auth"], result["blocking"]
  end

  def test_malformed_manifests_are_rejected_without_partial_evaluation
    malformed_manifests.each { |label, facts| assert_rejected(facts, label) }
  end

  def test_skill_links_both_references
    skill = File.read(SKILL_PATH, encoding: "UTF-8")

    assert_includes skill, "references/fact-gate.md"
    assert_includes skill, "references/execution-control.md"
  end

  def test_execution_control_declares_all_six_sections
    text = File.read(EXECUTION_CONTROL, encoding: "UTF-8")

    missing = CONTROL_SECTIONS.reject { |heading| text.include?(heading) }

    assert_empty missing
  end

  def test_execution_control_gives_each_section_a_contract_mechanism_and_evidence
    text = File.read(EXECUTION_CONTROL, encoding: "UTF-8")
    counts = %w[Contract Mechanism Evidence].map { |label| text.scan(/^#{label}: /).length }

    assert_equal [6, 6, 6], counts
  end

  def test_references_stay_within_the_reference_size_limit
    [FACT_GATE, EXECUTION_CONTROL].each do |path|
      assert_operator File.readlines(path, encoding: "UTF-8").length, :<=, 500, path
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(VALIDATE_PATH, encoding: "UTF-8")

    assert_includes validator, "test/agent_workflow_contracts_system_test.rb"
  end
end
