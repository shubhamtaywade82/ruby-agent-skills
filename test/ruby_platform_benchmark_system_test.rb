# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RubyPlatformBenchmarkSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  FAMILIES = {
    "ruby-toolchain" => "ruby-toolchain-contract",
    "ruby-gem-development" => "ruby-gem-development-contract"
  }.freeze

  def load_yaml(path)
    YAML.safe_load(
      File.read(path, encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
  end

  def fixture_contract_present?(family, eval_id)
    registry = load_yaml(
      File.join(ROOT, "benchmarks", family, "fixtures.yml")
    )
    fixture = registry.fetch("fixtures").fetch(eval_id)
    fixture_root = File.join(ROOT, fixture.fetch("root"))
    implementation = File.join(
      fixture_root,
      fixture.fetch("implementation_file")
    )
    reference_root = File.join(
      ROOT,
      "benchmarks",
      family,
      "references",
      eval_id
    )

    File.file?(implementation) &&
      File.directory?(reference_root) &&
      Dir.glob(File.join(reference_root, "**", "*")).any? do |path|
        File.file?(path)
      end
  end

  def test_each_campaign_declares_its_public_evaluation
    FAMILIES.each do |family, eval_id|
      campaign = load_yaml(
        File.join(ROOT, "benchmarks", family, "campaign.yml")
      )

      assert_equal [eval_id], Array(campaign.fetch("evaluations"))
      assert_equal 3, campaign.dig("execution", "repetitions")
      assert_equal "external-only", campaign.dig("controls", "hidden_cases")
    end
  end

  def test_each_campaign_uses_controlled_paired_execution
    expected = {
      "paired" => true,
      "fresh_workspace_per_run" => true,
      "same_fixture_for_pair" => true,
      "require_same_agent_command_when_using_agent_command" => true
    }

    FAMILIES.each_key do |family|
      execution = load_yaml(
        File.join(ROOT, "benchmarks", family, "campaign.yml")
      ).fetch("execution")

      assert_equal expected, execution.slice(*expected.keys)
    end
  end

  def test_each_fixture_registry_has_pristine_implementation_and_reference
    assert(
      FAMILIES.all? do |family, eval_id|
        fixture_contract_present?(family, eval_id)
      end
    )
  end

  def test_public_evaluations_are_benchmark_backed
    FAMILIES.each_key do |family|
      eval_file = File.join(ROOT, "evals", family, "contract.yml")

      assert_operator(
        load_yaml(eval_file).fetch("coverage", "benchmark-backed"),
        :!=,
        "static-only"
      )
    end
  end

  def test_verifiers_exist_and_validate_registers_this_test
    validator = File.read(
      File.join(ROOT, "bin", "validate"),
      encoding: "UTF-8"
    )

    FAMILIES.each_key do |family|
      assert File.file?(
        File.join(
          ROOT,
          "scripts",
          "verify_#{family.tr("-", "_")}_eval.rb"
        )
      )
    end

    assert_includes validator, "test/ruby_platform_benchmark_system_test.rb"
  end
end
