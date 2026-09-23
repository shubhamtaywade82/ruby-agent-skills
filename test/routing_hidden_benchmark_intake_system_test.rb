# frozen_string_literal: true

require "digest"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingHiddenBenchmarkIntakeSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  RUNNER = File.join(ROOT, "bin", "routing-hidden-benchmark-intake")

  def test_accepts_external_evidence_and_emits_safe_receipt
    Dir.mktmpdir("hidden-intake") do |dir|
      artifact = File.join(dir, "private-evidence.json")
      File.write(artifact, '{"external":true}')
      evidence = {
        "protocol_version" => 1,
        "benchmark" => "skill-routing-hidden-v1",
        "source" => "external-only",
        "case_count" => 17,
        "repetitions" => 6,
        "completed_runs" => 102,
        "agent" => {"provider" => "ollama", "model" => "private-model"},
        "artifact" => {
          "path" => artifact,
          "sha256" => Digest::SHA256.file(artifact).hexdigest,
          "bytes" => File.size(artifact)
        }
      }
      input = File.join(dir, "external.json")
      output = File.join(dir, "receipt.json")
      File.write(input, JSON.pretty_generate(evidence))

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, RUNNER, input,
        "--expected-runs", "102",
        "--provider", "ollama",
        "--model", "private-model",
        "--output", output,
        chdir: ROOT
      )

      assert status.success?, "#{stdout}
#{stderr}"
      receipt = JSON.parse(File.read(output, encoding: "UTF-8"))
      assert_equal true, receipt.fetch("verification").fetch("passed")
      assert_equal false, receipt.fetch("verification").fetch("gold_labels_in_repository")
      assert_equal 102, receipt.fetch("external_execution").fetch("completed_runs")
      refute receipt.key?("cases")
      refute receipt.key?("gold_labels")
      refute receipt.key?("prompts")
    end
  end

  def test_rejects_hidden_payload_fields
    Dir.mktmpdir("hidden-intake") do |dir|
      artifact = File.join(dir, "private-evidence.json")
      File.write(artifact, "{}")
      evidence = {
        "protocol_version" => 1,
        "benchmark" => "skill-routing-hidden-v1",
        "source" => "external-only",
        "case_count" => 1,
        "repetitions" => 1,
        "completed_runs" => 1,
        "agent" => {"provider" => "ollama", "model" => "private-model"},
        "cases" => ["secret prompt"],
        "artifact" => {
          "path" => artifact,
          "sha256" => Digest::SHA256.file(artifact).hexdigest,
          "bytes" => File.size(artifact)
        }
      }
      input = File.join(dir, "external.json")
      File.write(input, JSON.pretty_generate(evidence))

      _stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, RUNNER, input,
        "--expected-runs", "1",
        "--provider", "ollama",
        "--model", "private-model",
        chdir: ROOT
      )

      refute status.success?
      assert_includes stderr, "forbidden hidden payload fields"
    end
  end

  def test_private_expected_run_count_is_not_derived_from_public_corpus
    source = File.read(RUNNER, encoding: "UTF-8")
    assert_includes source, "--expected-runs"
    refute_includes source, "ROUTING_CASES.yml"
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_hidden_benchmark_intake_system_test.rb"
  end
end
