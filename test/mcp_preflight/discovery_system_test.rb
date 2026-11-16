# frozen_string_literal: true

require_relative "../support/mcp_preflight_test_case"

class McpPreflightDiscoverySystemTest < McpPreflightTestCase
  def test_discovery_requires_supported_versions_and_cache_metadata
    error = assert_raises(RubyAgentSkills::MCPPreflight::Error) do
      RubyAgentSkills::MCPPreflight::DiscoveryResult.new(
        "resultType" => "complete",
        "capabilities" => { "tools" => {} },
        "cacheScope" => "public",
        "ttlMs" => 1
      )
    end

    assert_equal "invalid_discovery", error.code
  end

  def test_requested_tool_is_found_on_a_later_tools_list_page
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "query_database",
      tools: [],
      tool_pages: [%w[schema_graph], %w[query_database]]
    )

    assert_equal "healthy", result.dig(:health, :status)
    assert_includes result.dig(:health, :tools), "query_database"
    assert_equal "approval_required", result[:decision]
  end

  def test_tool_inventory_rejects_duplicate_names_across_pages
    error = assert_raises(RubyAgentSkills::MCPPreflight::Error) do
      RubyAgentSkills::MCPPreflight::ToolInventory.collect do |cursor, _page|
        response = { "tools" => [{ "name" => "read_model" }] }
        response["nextCursor"] = "next" unless cursor
        response
      end
    end

    assert_equal "invalid_tools_list", error.code
  end

  def test_tool_inventory_rejects_unbounded_pagination
    error = assert_raises(RubyAgentSkills::MCPPreflight::Error) do
      RubyAgentSkills::MCPPreflight::ToolInventory.collect do |_cursor, _page|
        { "tools" => [], "nextCursor" => "again" }
      end
    end

    assert_equal "pagination_limit", error.code
  end

end
