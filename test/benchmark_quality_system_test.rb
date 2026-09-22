# frozen_string_literal: true

require "minitest/autorun"
require "open3"

class BenchmarkQualitySystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_benchmark_quality_audit_passes
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "scripts", "audit_benchmark_quality.rb"),
      chdir: ROOT
    )

    assert status.success?, "#{stdout}\n#{stderr}"
    assert_includes stdout, "Benchmark quality audit passed."
  end

  def test_public_campaigns_use_controlled_paired_execution
    Dir[File.join(ROOT, "benchmarks", "*", "campaign.yml")].each do |path|
      text = File.read(path, encoding: "UTF-8")
      %w[
        paired: true
        fresh_workspace_per_run: true
        same_fixture_for_pair: true
        require_same_agent_command_when_using_agent_command: true
      ].each { |contract| assert_includes text, contract, "#{path} missing #{contract}" }
      assert_match(/repetitions:\s+3/, text, "#{path} must default to three repetitions")
      assert_includes text, "hidden_cases: external-only", "#{path} must disclose public/hidden benchmark boundary"
    end
  end

  def test_benchmark_campaign_result_schema_keeps_provenance
    schema = File.read(File.join(ROOT, "docs", "BENCHMARK_CAMPAIGN_RESULT_SCHEMA.md"), encoding: "UTF-8")
    %w[campaign_version evaluation_set source fixture_root verifier execution controls].each do |field|
      assert_includes schema, field
    end
  end
end
