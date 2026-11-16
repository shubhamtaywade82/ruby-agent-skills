# frozen_string_literal: true

require_relative "../support/mcp_preflight_test_case"

class McpPreflightProtocolSystemTest < McpPreflightTestCase
  def test_modern_stdio_discovery_lists_the_live_tool_and_allows_inspection
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "schema_graph",
      tools: %w[schema_graph run_tests],
      profile: "inspect"
    )

    assert_modern_probe_result(result)
  end

  def test_legacy_stdio_server_falls_back_to_initialize
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "schema_graph",
      tools: %w[schema_graph],
      modern: false
    )

    assert_equal "healthy", result.dig(:health, :status)
    assert_equal "2025-11-25", result.dig(:health, :protocol_version)
    assert_equal "allowed", result[:decision]
  end

  def test_discovery_negotiates_legacy_when_modern_is_not_advertised
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "schema_graph",
      tools: %w[schema_graph],
      supported_versions: ["2025-11-25"]
    )

    assert_equal "healthy", result.dig(:health, :status)
    assert_equal "2025-11-25", result.dig(:health, :protocol_version)
    assert_includes result.dig(:health, :tools), "schema_graph"
  end

  def test_discovery_fails_closed_when_no_client_version_is_supported
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "schema_graph",
      tools: %w[schema_graph],
      supported_versions: ["2024-11-05"]
    )

    assert_equal "unavailable", result[:decision]
    assert_match(/no protocol version supported/, result.dig(:health, :reason))
  end

  def test_discovery_without_tools_capability_returns_healthy_empty_inventory
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "schema_graph",
      tools: %w[schema_graph],
      supports_tools: false
    )

    assert_equal "healthy", result.dig(:health, :status)
    assert_empty result.dig(:health, :tools)
    assert_equal "unavailable", result[:decision]
  end

  def test_silent_legacy_stdio_probe_restarts_server_for_initialize
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "schema_graph",
      tools: %w[schema_graph],
      modern: false,
      silence_first_discovery: true
    )

    assert_equal "healthy", result.dig(:health, :status)
    assert_equal "2025-11-25", result.dig(:health, :protocol_version)
    assert_includes result.dig(:health, :tools), "schema_graph"
  end

end
