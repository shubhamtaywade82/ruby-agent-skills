# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

class RubyPlatformBenchmarkSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  CAMPAIGN = File.join(ROOT, "benchmarks", "ruby-platform", "campaign.yml")
  REGISTRY = File.join(ROOT, "benchmarks", "ruby-platform", "fixtures.yml")
  VERIFIER = File.join(ROOT, "scripts", "verify_ruby_platform_eval.rb")

  def load_yaml(path)
    YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [], aliases: false)
  end

  def test_campaign_is_complete_and_covers_both_foundations
    assert File.file?(CAMPAIGN)
    campaign = load_yaml(CAMPAIGN)

    assert_equal "ruby-platform", campaign.fetch("evaluation_set")
    assert_equal %w[ruby-toolchain-contract ruby-gem-development-contract],
                 Array(campaign.fetch("evaluations")).sort
    assert_equal 3, campaign.dig("execution", "repetitions")
    assert_equal true, campaign.dig("execution", "paired")
    assert_equal true, campaign.dig("execution", "fresh_workspace_per_run")
    assert_equal true, campaign.dig("execution", "same_fixture_for_pair")
    assert_equal "external-only", campaign.dig("controls", "hidden_cases")
  end

  def test_fixture_registry_has_pristine_implementation_and_reference_for_each_eval
    assert File.file?(REGISTRY)
    registry = load_yaml(REGISTRY)

    expected = %w[ruby-toolchain-contract ruby-gem-development-contract]

    expected.each do |eval_id|
      fixture = registry.fetch("fixtures").fetch(eval_id)
      fixture_root = File.join(ROOT, fixture.fetch("root"))
      implementation = File.join(fixture_root, fixture.fetch("implementation_file"))
      reference_root = File.join(ROOT, "benchmarks", "ruby-platform", "references", eval_id)

      assert File.file?(implementation), "missing fixture implementation for #{eval_id}"
      assert File.directory?(reference_root), "missing reference for #{eval_id}"
      assert Dir.glob(File.join(reference_root, "**", "*")).any? { |path| File.file?(path) },
             "reference for #{eval_id} is empty"
    end
  end

  def test_public_evaluations_are_benchmark_backed
    paths = [
      File.join(ROOT, "evals", "ruby-toolchain", "contract.yml"),
      File.join(ROOT, "evals", "ruby-gem-development", "contract.yml")
    ]

    paths.each do |path|
      data = load_yaml(path)
      refute_equal "static-only", data.fetch("coverage", nil), path
    end
  end

  def test_verifier_exists_and_validate_registers_this_test
    assert File.file?(VERIFIER)
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/ruby_platform_benchmark_system_test.rb"
  end
end
