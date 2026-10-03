# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

# The runner smoke test and fixture contract share this focused platform boundary.
# rubocop:disable Metrics/ClassLength
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
    File.file?(implementation_path(fixture_data)) &&
      reference_files?(family, eval_id)
  end

  def implementation_path(fixture_data)
    File.join(
      ROOT,
      fixture_data.fetch("root"),
      fixture_data.fetch("implementation_file")
    )
  end

  def reference_files?(family, eval_id)
    reference_root = File.join(ROOT, "benchmarks", family, "references", eval_id)

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
      execution = campaign(family).fetch("execution")

      assert_equal EXPECTED_EXECUTION, execution.slice(*EXPECTED_EXECUTION.keys)
    end
  end

  def test_each_fixture_registry_has_pristine_reference
    assert(
      FAMILIES.all? do |family, eval_id|
        reference_present?(family, eval_id, fixture(family, eval_id))
      end
    )
  end

  def campaign_command(family, output)
    [
      RbConfig.ruby, File.join(ROOT, "bin", "benchmark"), "campaign",
      "--manifest", File.join(ROOT, "benchmarks", family, "campaign.yml"),
      "--agent-command", "true", "--runs", "3", "--continue-on-failure",
      "--output", output
    ]
  end

  def campaign_result(family, output)
    path = File.join(output, "campaign.json")
    return unless File.file?(path)

    JSON.parse(File.read(path, encoding: "UTF-8"))
      .dig("evaluations", FAMILIES.fetch(family))
  end

  def campaign_succeeds?(family)
    Dir.mktmpdir("ruby-platform-campaign") do |output|
      _, _, status = Open3.capture3(*campaign_command(family, output), chdir: ROOT)
      result = campaign_result(family, output)

      status.success? &&
        result &&
        result.dig("complete") == true &&
        result.fetch("baseline_completed_repetitions") == 3 &&
        result.fetch("skills_completed_repetitions") == 3
    rescue StandardError
      false
    end
  end

  def test_campaign_runner_completes_three_paired_repetitions
    failures = FAMILIES.keys.reject { |family| campaign_succeeds?(family) }

    assert_empty failures, "campaign runner did not complete the Ruby foundation smoke campaigns"
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
      verifier = "verify_#{family.tr('-', '_')}_eval.rb"

      assert File.file?(File.join(ROOT, "scripts", verifier))
    end

    assert_includes validator, "test/ruby_platform_benchmark_system_test.rb"
  end
end

# rubocop:enable Metrics/ClassLength
