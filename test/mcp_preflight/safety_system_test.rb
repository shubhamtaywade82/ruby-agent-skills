# frozen_string_literal: true

require_relative "../support/mcp_preflight_test_case"

class McpPreflightSafetySystemTest < McpPreflightTestCase
  def test_production_access_and_credential_export_are_unconditionally_denied
    policy = hard_deny_policy

    %w[open_production export_credentials].each do |tool|
      assert_equal "denied", hard_deny_decision(policy, tool)
    end
  end

  def hard_deny_policy
    path = File.join(@tmpdir, "hard-deny.yml")
    write_hard_deny_policy(path)
    RubyAgentSkills::MCPPreflight::Policy.new(path)
  end

  def hard_deny_decision(policy, tool)
    policy.evaluate(
      server: "example",
      tool: tool,
      profile: "maintenance",
      environment: "development",
      isolated: true
    ).fetch(:decision)
  end

  def test_remote_plain_http_is_rejected_before_network_access
    error = assert_raises(RubyAgentSkills::MCPPreflight::Error) do
      http_probe("http://example.com/mcp").call
    end
    assert_equal "unsafe_url", error.code
  end

  def test_ipv6_loopback_plain_http_is_allowed
    assert_nil http_probe("http://[::1]:3000/mcp").send(:validate_url!)
  end

  def test_policy_rejects_a_non_deny_unknown_tool_default
    policy_path = File.join(@tmpdir, "unsafe-policy.yml")
    policy = File.read(POLICY, encoding: "UTF-8").sub("unknown_tool: deny", "unknown_tool: allow")
    File.write(policy_path, policy, encoding: "UTF-8")

    error = assert_raises(RubyAgentSkills::MCPPreflight::Error) do
      RubyAgentSkills::MCPPreflight::Policy.new(policy_path)
    end

    assert_equal "invalid_policy", error.code
  end

  def test_validator_executes_this_system_test
    validate = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validate, "test/mcp_preflight_system_test.rb"
  end
end
