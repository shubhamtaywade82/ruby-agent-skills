# frozen_string_literal: true

require_relative "../support/mcp_preflight_test_case"

class McpPreflightPolicySystemTest < McpPreflightTestCase
  def test_database_reads_require_human_approval_under_inspect_profile
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "query_database",
      tools: %w[query_database]
    )

    assert_equal "healthy", result.dig(:health, :status)
    assert_equal "approval_required", result[:decision]
    assert_equal "application_data_read", result[:capability]
  end

  def test_model_reads_require_human_approval_under_inspect_profile
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "read_model",
      tools: %w[read_model]
    )

    assert_equal "approval_required", result[:decision]
    assert_equal "application_data_read", result[:capability]
  end

  def test_test_execution_requires_an_isolated_test_environment
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "run_tests",
      tools: %w[run_tests],
      profile: "test",
      environment: "test",
      isolated: true
    )

    assert_equal "allowed", result[:decision]
    assert_equal "test_execution", result[:capability]
  end

  def test_test_execution_is_denied_without_isolation
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "run_tests",
      tools: %w[run_tests],
      profile: "test",
      environment: "test"
    )

    assert_equal "denied", result[:decision]
    assert_match(/isolated environment/, result[:reason])
  end

  def test_shell_execution_requires_isolation_and_then_human_approval
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "run_command",
      tools: %w[run_command],
      profile: "maintenance",
      isolated: true
    )

    assert_equal "approval_required", result[:decision]
    assert_equal "shell_execution", result[:capability]
  end

  def test_unclassified_tool_is_denied_without_starting_server
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "new_sensitive_tool",
      tools: %w[new_sensitive_tool]
    )

    assert_equal "not_checked", result.dig(:health, :status)
    assert_equal "denied", result[:decision]
    assert_match(/unclassified/, result[:reason])
  end
end
