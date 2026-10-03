# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RubyPlatformBenchmarkSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  FAMILIES = {
    "ruby-toolchain" => "ruby-toolchain-contract",
    "ruby-gem-development" => "ruby-gem-development-contract"
  }.freeze
  EXPECTED_EXECUTION = {
    "paired" => true,
    "fresh_workspace_per_run" => true,
    "same_fixture_for_pair" => true,
    "require_same_agent_command_when_using_agent_command" => true
  }.freeze

  def load_yaml(path)
    YAML.safe_load(
      File.read(path, encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )
  end

  def campaign(family)
    load_yaml(File.join(ROOT, "benchmarks", family, "campaign.yml"))
  end

  def fixture(family, eval_id)
    load_yaml(File.join(ROOT, "benchmarks", family, "fixtures.yml"))
      .fetch("fixtures")
      .fetch(eval_id)
  end

  def reference_present?(family, eval_id, fixture_data)
    fixture_root = File.join(ROOT, fixture_data.fetch("root"))
    implementation = File.join(
      fixture_root,
      fixture_data.fetch("implementation_file")
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
      Dir.glob(File.join(reference_root, "**", "*")).any? { |path| File.file?(path) }
  end

  def test_each_campaign_declares_its_public_evaluation
    FAMILIES.each do |family, eval_id|
      data = campaign(family)

      assert_equal [eval_id], Array(data.fetch("evaluations"))
      assert_equal 3, data.dig("execution", "repetitions")
      assert_equal "external-only", data.dig("controls", "hidden_cases")
    end
  end

  def test_each_campaign_uses_controlled_paired_execution
    FAMILIES.each_key do |family|
      assert_equal EXPECTED_EXECUTION, campaign(family).fetch("execution").slice(*EXPECTED_EXECUTION.keys)
    end
  end

  def test_each_fixture_registry_has_pristine_reference
    assert(
      FAMILIES.all? do |family, eval_id|
        reference_present?(family, eval_id, fixture(family, eval_id))
      end
    )
  end

  def test_public_evaluations_are_benchmark_backed
    FAMILIES.each_key do |family|
      eval_file = File.join(ROOT, "evals", family, "contract.yml")

      refute_equal "static-only", load_yaml(eval_file).fetch("coverage", "benchmark-backed")
    end
  end

  def test_verifiers_exist_and_validate_registers_this_test
    validator = File.read(
      File.join(ROOT, "bin", "validate"),
      encoding: "UTF-8"
    )

    FAMILIES.each_key do |family|
      assert File.file?(
        File.join(ROOT, "scripts", "verify_#{family.tr("-", "_")}_eval.rb")
      )
    end

    assert_includes validator, "test/ruby_platform_benchmark_system_test.rb"
  end
end
