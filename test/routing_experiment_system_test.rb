# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RoutingExperimentSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_experiment_keeps_agent_configuration_fixed_and_detects_improvement
    Dir.mktmpdir("routing-experiment") do |dir|
      baseline_router = File.join(dir, "baseline.md")
      candidate_router = File.join(dir, "candidate.md")
      output = File.join(dir, "output")

      File.write(baseline_router, "# Routing contract\nBASELINE\n")
      File.write(candidate_router, "# Routing contract\nCANDIDATE\n")

      command = "ruby -rjson -e 'router=ENV.fetch(%q[RUBY_AGENT_ROUTING_ROUTER_FILE]); result=ENV.fetch(%q[RUBY_AGENT_ROUTING_RESULT_FILE]); candidate=File.read(router).include?(%q[CANDIDATE]); case_id=ENV.fetch(%q[RUBY_AGENT_ROUTING_CASE_ID]); improved=(candidate && case_id == %q[password-recovery-not-authorization]); payload={protocol_version:1,case_id:case_id,primary_skill:(improved ? %q[rails-authentication] : %q[rails-active-record]),secondary_skills:[],reason:%q[test]}; File.write(result, JSON.generate(payload))'"

      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-experiment"),
        "--command", command,
        "--baseline-router", baseline_router,
        "--candidate-router", candidate_router,
        "--provider", "test",
        "--model", "test-model",
        "--tool-mode", "test",
        "--output", output,
        chdir: ROOT
      )

      assert status.success?, "#{stdout}\n#{stderr}"

      baseline = JSON.parse(File.read(File.join(output, "baseline.json"), encoding: "UTF-8"))
      candidate = JSON.parse(File.read(File.join(output, "candidate.json"), encoding: "UTF-8"))
      comparison = JSON.parse(File.read(File.join(output, "comparison.json"), encoding: "UTF-8"))

      assert_equal false, baseline.fetch("metrics").fetch("primary_accuracy") == 1.0
      assert_in_delta 1.0.fdiv(14), candidate.fetch("metrics").fetch("primary_accuracy"), 0.0001
      assert_equal true, comparison.fetch("gate").fetch("passed")
      assert_equal "test-model", baseline.fetch("agent").fetch("model")
      assert_equal "test-model", candidate.fetch("agent").fetch("model")
      assert_equal File.expand_path(baseline_router), baseline.fetch("routing_contract")
      assert_equal File.expand_path(candidate_router), candidate.fetch("routing_contract")
    end
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_experiment_system_test.rb"
  end
end
