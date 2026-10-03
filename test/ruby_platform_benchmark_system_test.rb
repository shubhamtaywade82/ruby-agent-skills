# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RubyPlatformBenchmarkSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  CAMPAIGN = File.join(ROOT, "benchmarks", "ruby-platform", "campaign.yml")
  REGISTRY = File.join(ROOT, "benchmarks", "ruby-platform", "fixtures.yml")
  VERIFIER = File.join(ROOT, "scripts", "verify_ruby_platform_eval.rb")
  EVALUATIONS = %w[ruby-toolchain-contract ruby-gem-development-contract].freeze

  def load_yaml(path)
    YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
  end

  def fixture_contract_present?(registry, eval_id)
    fixture = registry.fetch("fixtures").fetch(eval_id)
    fixture_root = File.join(ROOT, fixture.fetch("root"))
    implementation = File.join(fixture_root, fixture.fetch("implementation_file"))
    reference_root = File.join(ROOT, "benchmarks", "ruby-platform", "references", eval_id)

    File.file?(implementation) &&
      File.directory?(reference_root) &&
      Dir.glob(File.join(reference_root, "**", "*")).any? { |path| File.file?(path) }
  end

  def test_campaign_declares_both_foundations
    campaign = load_yaml(CAMPAIGN)

    assert_equal EVALUATIONS, Array(campaign.fetch("evaluations")).sort
    assert_equal 3, campaign.dig("execution", "repetitions")
    assert_equal "external-only", campaign.dig("controls", "hidden_cases")
  end

  def test_campaign_uses_controlled_paired_execution
    execution = load_yaml(CAMPAIGN).fetch("execution")
    expected = {
      "paired" => true,
      "fresh_workspace_per_run" => true,
      "same_fixture_for_pair" => true,
      "require_same_agent_command_when_using_agent_command" => true
    }

    assert_equal expected, execution.slice(*expected.keys)
  end

  def test_fixture_registry_has_pristine_implementation_and_reference
    registry = load_yaml(REGISTRY)

    assert EVALUATIONS.all? { |eval_id| fixture_contract_present?(registry, eval_id) }
  end

  def test_public_evaluations_are_benchmark_backed
    paths = [
      File.join(ROOT, "evals", "ruby-toolchain", "contract.yml"),
      File.join(ROOT, "evals", "ruby-gem-development", "contract.yml")
    ]

    assert(
      paths.all? do |path|
        load_yaml(path).fetch("coverage", "benchmark-backed") != "static-only"
      end
    )
  end

  def test_verifier_exists_and_validate_registers_this_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert File.file?(VERIFIER)

    assert_includes validator, "test/ruby_platform_benchmark_system_test.rb"
  end
end
