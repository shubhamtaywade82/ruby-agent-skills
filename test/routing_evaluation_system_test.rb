# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

class RoutingEvaluationSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_routing_evaluation_case_file_is_valid
    data = YAML.safe_load(
      File.read(File.join(ROOT, "router", "ROUTING_CASES.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )

    assert_equal 14, Array(data.fetch("cases")).length
    assert Array(data.fetch("cases")).all? do |entry|
      entry.fetch("primary_skills").length == 1 &&
        entry.fetch("secondary_skills").none? { |skill| skill == entry.fetch("primary_skills").first }
    end
  end

  def test_routing_evaluator_produces_measurement
    Dir.mktmpdir("routing-eval") do |dir|
      command = "ruby -rjson -e 'result=ENV.fetch(%q[RUBY_AGENT_ROUTING_RESULT_FILE]); File.write(result, JSON.generate({protocol_version:1,case_id:ENV.fetch(%q[RUBY_AGENT_ROUTING_CASE_ID]),primary_skill:%q[rails-authentication],secondary_skills:[%q[rails-security-engineering],%q[rails-test-engineering]],reason:%q[Authentication owns the identity lifecycle.]}) + %q[\n])'"

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-eval"),
        "--command", command,
        "--case", "password-recovery-not-authorization",
        "--output", File.join(dir, "campaign.json"),
        chdir: ROOT
      )

      assert status.success?, "#{stdout}\n#{stderr}"

      campaign = JSON.parse(File.read(File.join(dir, "campaign.json"), encoding: "UTF-8"))
      assert_equal true, campaign.fetch("complete")
      assert_in_delta 1.0, campaign.fetch("metrics").fetch("primary_accuracy"), 0.0001
      assert_in_delta 1.0, campaign.fetch("metrics").fetch("secondary_recall"), 0.0001
    end
  end

  def test_manifest_registers_routing_contract
    manifest = YAML.safe_load(
      File.read(File.join(ROOT, "skill-manifest.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )

    routing = manifest.fetch("routing")
    assert_equal "router/ROUTING.md", routing.fetch("contract")
    assert_equal "router/ROUTING_CASES.yml", routing.fetch("cases")
    assert_equal "scripts/audit_skill_routing.rb", routing.fetch("audit")
    assert_equal "docs/ROUTING_EVAL_RESULT_SCHEMA.md", routing.fetch("result_schema")
    assert_equal "bin/routing-eval", routing.fetch("evaluation_runner")
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_evaluation_system_test.rb"
  end
end
