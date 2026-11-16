# frozen_string_literal: true

require_relative "../support/mcp_preflight_test_case"

class McpPreflightFakeHttpTransport
  attr_reader :notified

  def initialize(tools: [], supports_tools: true)
    @tools = tools
    @supports_tools = supports_tools
  end

  def post(method, _params, _id, **_options)
    method == "initialize" ? initialize_response : tools_response
  end

  def notify_initialized
    @notified = true
  end

  private

  def initialize_response
    capabilities = @supports_tools ? { "tools" => {} } : {}
    {
      result: {
        "protocolVersion" => "2025-11-25",
        "capabilities" => capabilities,
        "serverInfo" => { "name" => "legacy-http", "version" => "1.0" }
      }
    }
  end

  def tools_response
    { result: { "tools" => @tools.map { |name| { "name" => name } } } }
  end
end

class McpPreflightHttpSystemTest < McpPreflightTestCase
  def test_legacy_http_probe_initializes_and_lists_tools
    transport = McpPreflightFakeHttpTransport.new(tools: %w[schema_graph run_tests])
    result = RubyAgentSkills::MCPPreflight::LegacyHttpProbe.new(transport).call

    assert_equal "2025-11-25", result[:protocol_version]
    assert_equal %w[run_tests schema_graph], result[:tools]
    assert transport.notified
    assert_equal "legacy-http", result.dig(:server_info, :name)
  end

  def test_modern_http_probe_returns_tool_names_not_tool_objects
    probe = http_probe("https://example.com/mcp")
    transport = McpPreflightFakeHttpTransport.new(tools: %w[schema_graph run_tests])
    probe.instance_variable_set(:@transport, transport)

    assert_equal %w[run_tests schema_graph], probe.send(:collect_tools, {}, 2)
  end

  def test_legacy_http_probe_skips_tool_list_without_tools_capability
    transport = McpPreflightFakeHttpTransport.new(supports_tools: false)
    result = RubyAgentSkills::MCPPreflight::LegacyHttpProbe.new(transport).call

    assert_empty result[:tools]
    assert_equal "healthy", result[:status]
  end

  def test_http_mcp_url_rejects_embedded_credentials
    error = assert_raises(RubyAgentSkills::MCPPreflight::Error) do
      http_probe("https://user:secret@example.com/mcp").send(:validate_url!)
    end

    assert_equal "unsafe_url", error.code
  end

  def test_http_mcp_url_rejects_fragments
    error = assert_raises(RubyAgentSkills::MCPPreflight::Error) do
      http_probe("https://example.com/mcp#fragment").send(:validate_url!)
    end

    assert_equal "unsafe_url", error.code
  end
end
