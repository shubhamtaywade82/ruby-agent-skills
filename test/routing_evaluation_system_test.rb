# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "socket"
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
      command = "ruby -rjson -e 'case_file=ENV.fetch(%q[RUBY_AGENT_ROUTING_CASE_FILE]); abort(%q[gold labels leaked]) if File.read(case_file).include?(%q[primary_skills]); result=ENV.fetch(%q[RUBY_AGENT_ROUTING_RESULT_FILE]); File.write(result, JSON.generate({protocol_version:1,case_id:ENV.fetch(%q[RUBY_AGENT_ROUTING_CASE_ID]),primary_skill:%q[rails-authentication],secondary_skills:[%q[rails-security-engineering],%q[rails-test-engineering]],reason:%q[Authentication owns the identity lifecycle.]}))'"

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
      assert_equal 3, campaign.fetch("requested_repetitions")
      assert_equal 3, campaign.fetch("completed_runs")
      assert_equal 3, campaign.fetch("confusion_matrix").fetch("rails-authentication").fetch("rails-authentication")
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
    assert_equal "router/ROUTING_CAMPAIGN.yml", routing.fetch("campaign_manifest")
    assert_equal "bin/routing-agent-ollama", routing.fetch("ollama_adapter")
    assert_equal "bin/routing-campaign", routing.fetch("campaign_runner")
    assert_equal "bin/routing-analyze", routing.fetch("campaign_analyzer")
    assert_equal "router/ROUTING_REMEDIATION.yml", routing.fetch("remediation_policy")
    assert_equal "bin/routing-compare", routing.fetch("remediation_comparator")
  end

  def test_validator_executes_this_system_test
    validator = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")
    assert_includes validator, "test/routing_evaluation_system_test.rb"
  end
end

class RoutingCampaignContractSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_campaign_manifest_is_three_repetition_and_external_hidden_case_safe
    campaign = YAML.safe_load(
      File.read(File.join(ROOT, "router", "ROUTING_CAMPAIGN.yml"), encoding: "UTF-8"),
      permitted_classes: [],
      aliases: false
    )

    assert_equal "skill-routing-public-v1", campaign.fetch("id")
    assert_equal 3, campaign.fetch("execution").fetch("repetitions")
    assert_equal true, campaign.fetch("execution").fetch("fresh_workspace_per_run")
    assert_equal "external-only", campaign.fetch("controls").fetch("hidden_cases")
  end
end


class OllamaRoutingAgentSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_ollama_adapter_normalizes_model_output
    server = TCPServer.new("127.0.0.1", 0)
    port = server.addr[1]
    request_body = nil

    server_thread = Thread.new do
      socket = server.accept
      request = +""
      request << socket.readpartial(16_384)
      header, body = request.split("\r\n\r\n", 2)
      content_length = header[/Content-Length:\s*(\d+)/i, 1].to_i
      while body.bytesize < content_length
        body << socket.readpartial(16_384)
      end
      request_body = JSON.parse(body)

      response_body = JSON.generate(
        "message" => {
          "content" => JSON.generate(
            "primary_skill" => "rails-authentication",
            "secondary_skills" => ["rails-security-engineering"],
            "reason" => "The task concerns identity lifecycle."
          )
        }
      )

      socket.write(
        "HTTP/1.1 200 OK\r\n"         "Content-Type: application/json\r\n"         "Content-Length: #{response_body.bytesize}\r\n"         "Connection: close\r\n\r\n#{response_body}"
      )
      socket.close
    end

    Dir.mktmpdir("ollama-routing") do |dir|
      prompt_file = File.join(dir, "prompt.txt")
      result_file = File.join(dir, "result.json")
      File.write(prompt_file, "Implement password reset with replay protection.\n")

      env = {
        "RUBY_AGENT_ROUTING_PROTOCOL_VERSION" => "1",
        "RUBY_AGENT_ROUTING_CASE_ID" => "password-recovery-not-authorization",
        "RUBY_AGENT_ROUTING_PROMPT_FILE" => prompt_file,
        "RUBY_AGENT_ROUTING_RESULT_FILE" => result_file,
        "RUBY_AGENT_ROUTING_MANIFEST_FILE" => File.join(ROOT, "skill-manifest.yml"),
        "RUBY_AGENT_ROUTING_ROUTER_FILE" => File.join(ROOT, "router", "ROUTING.md"),
        "OLLAMA_URL" => "http://127.0.0.1:#{port}",
        "OLLAMA_MODEL" => "test-model"
      }

      _stdout, stderr, status = Open3.capture3(
        env,
        RbConfig.ruby,
        File.join(ROOT, "bin", "routing-agent-ollama"),
        chdir: ROOT
      )

      assert status.success?, stderr

      result = JSON.parse(File.read(result_file, encoding: "UTF-8"))
      assert_equal "password-recovery-not-authorization", result.fetch("case_id")
      assert_equal "rails-authentication", result.fetch("primary_skill")
      assert_equal ["rails-security-engineering"], result.fetch("secondary_skills")
      assert_equal "test-model", request_body.fetch("model")
      assert_equal false, request_body.fetch("stream")
      assert_equal "json", request_body.fetch("format")
    end
  ensure
    server.close if server
    server_thread.join if server_thread
  end
end
