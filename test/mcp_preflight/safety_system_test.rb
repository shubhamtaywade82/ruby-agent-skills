# frozen_string_literal: true

require_relative "../support/mcp_preflight_test_case"

class McpPreflightSafetySystemTest < McpPreflightTestCase
  def test_production_access_and_credential_export_are_unconditionally_denied
    policy_path = File.join(@tmpdir, "hard-deny.yml")
    File.write(
      policy_path,
      <<~YAML,
        schema_version: 1
        defaults:
          production: deny
          unknown_tool: deny
          isolated_capabilities: []
        profiles:
          maintenance:
            allow: [production_access, credential_export]
        servers:
          example:
            tools:
              open_production: production_access
              export_credentials: credential_export
      YAML
      encoding: "UTF-8"
    )
    policy = RubyAgentSkills::MCPPreflight::Policy.new(policy_path)

    %w[open_production export_credentials].each do |tool|
      result = policy.evaluate(
        server: "example",
        tool: tool,
        profile: "maintenance",
        environment: "development",
        isolated: true
      )
      assert_equal "denied", result[:decision]
    end
  end


  def test_remote_plain_http_is_rejected_before_network_access
    probe = RubyAgentSkills::MCPPreflight::StreamableHttpProbe.new(
      { "url" => "http://example.com/mcp" },
      timeout: 1
    )

    error = assert_raises(RubyAgentSkills::MCPPreflight::Error) { probe.call }
    assert_equal "unsafe_url", error.code
  end


  def test_ipv6_loopback_plain_http_is_allowed
    probe = RubyAgentSkills::MCPPreflight::StreamableHttpProbe.new(
      { "url" => "http://[::1]:3000/mcp" },
      timeout: 1
    )

    assert_nil probe.send(:validate_url!)
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
