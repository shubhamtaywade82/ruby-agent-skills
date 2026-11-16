# frozen_string_literal: true

require_relative "../support/mcp_preflight_test_case"

class McpPreflightAvailabilitySystemTest < McpPreflightTestCase
  def test_missing_server_registration_is_distinct_from_an_unhealthy_server
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "schema_graph",
      tools: %w[schema_graph],
      omit_server_config: true
    )

    assert_equal "unavailable", result.dig(:health, :status)
    assert_equal false, result.dig(:health, :configured)
  end


  def test_unresponsive_stdio_server_is_reported_unavailable
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "schema_graph",
      tools: %w[schema_graph],
      exit_early: true
    )

    assert_equal "unavailable", result.dig(:health, :status)
    assert_match(/server_exited/, result.dig(:health, :reason))
  end


  def test_tool_missing_from_live_tools_list_is_unavailable
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "query_database",
      tools: %w[schema_graph]
    )

    assert_equal "unavailable", result[:decision]
    assert_equal "healthy", result.dig(:health, :status)
  end


  def test_production_is_denied_even_for_read_only_capabilities
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "schema_graph",
      tools: %w[schema_graph],
      environment: "production"
    )

    assert_equal "not_checked", result.dig(:health, :status)
    assert_equal "denied", result[:decision]
    assert_match(/production environment/, result[:reason])
  end


  def test_preflight_requires_explicit_confirmation_before_starting_a_server
    error = assert_raises(RubyAgentSkills::MCPPreflight::Error) do
      run_preflight(
        server: "ask-rails-harness",
        tool: "schema_graph",
        tools: %w[schema_graph],
        probe: false
      )
    end

    assert_equal "probe_confirmation_required", error.code
  end


  def test_invalid_environment_is_rejected
    error = assert_raises(RubyAgentSkills::MCPPreflight::Error) do
      run_preflight(
        server: "rails",
        tool: "schema_graph",
        tools: %w[schema_graph],
        environment: "prodution"
      )
    end

    assert_equal "unknown_environment", error.code
  end


end
