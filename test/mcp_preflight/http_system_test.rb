# frozen_string_literal: true

require_relative "../support/mcp_preflight_test_case"

class McpPreflightFakeHttpTransport
  attr_reader :notified

  def initialize(tools: [], supports_tools: true, modern_discovery_supported: true)
    @tools = tools
    @supports_tools = supports_tools
    @modern_discovery_supported = modern_discovery_supported
  end

  def post(method, _params, _id, **_options)
    case method
    when "server/discover" then discovery_response
    when "initialize" then initialize_response
    when "tools/list" then tools_response
    end
  end

  def notify_initialized
    @notified = true
  end

  private

  def discovery_response
    return { error: { "code" => -32_601 } } unless @modern_discovery_supported

    {
      result: {
        "resultType" => "complete",
        "supportedVersions" => ["2026-07-28"],
        "capabilities" => { "tools" => {} },
        "cacheScope" => "public",
        "ttlMs" => 30_000,
        "_meta" => {
          "io.modelcontextprotocol/serverInfo" => {
            "name" => "modern-http",
            "version" => "2.0"
          }
        }
      }
    }
  end

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

  def test_modern_http_probe_reports_server_and_tool_inventory
    probe = http_probe("https://example.com/mcp")
    transport = McpPreflightFakeHttpTransport.new(tools: %w[schema_graph run_tests])
    probe.instance_variable_set(:@transport, transport)

    result = probe.call

    assert_equal "healthy", result[:status]
    assert_equal "modern-http", result.dig(:server_info, :name)
    assert_equal %w[run_tests schema_graph], result[:tools]
  end

  def test_http_probe_falls_back_when_modern_discovery_is_not_supported
    probe = http_probe("https://example.com/mcp")
    transport = McpPreflightFakeHttpTransport.new(
      tools: %w[schema_graph run_tests],
      modern_discovery_supported: false
    )
    probe.instance_variable_set(:@transport, transport)

    result = probe.call

    assert_equal "2025-11-25", result[:protocol_version]
    assert_equal "legacy-http", result.dig(:server_info, :name)
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
