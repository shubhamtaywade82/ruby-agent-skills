# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/ruby_agent_skills/mcp_server"

class McpServerSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def setup
    @server = RubyAgentSkills::MCP::Server.new(root: ROOT)
  end

  def test_tool_definitions_cover_the_contract_surface
    names = @server.tool_definitions.map { |tool| tool[:name] }
    expected = %w[list_skills get_skill route_prompt list_companions route_cross_pack]
    assert_equal expected.sort, names.sort
    @server.tool_definitions.each do |tool|
      assert tool[:inputSchema].is_a?(Hash), "#{tool[:name]}: inputSchema missing"
      refute_empty tool[:description], "#{tool[:name]}: description missing"
    end
  end

  def test_route_prompt_returns_primary_and_secondaries
    result = @server.call_tool("route_prompt", { "prompt" => "add a migration with an index" })

    assert_equal "rails-active-record", result[:primary]
    assert_includes result[:secondaries], "rails-data-modeling"
    assert_operator result[:candidates].length, :>=, 1
  end

  def test_route_prompt_reports_the_active_language
    result = @server.call_tool("route_prompt",
                               { "prompt" => "add a migration", "file" => "app/models/order.rb" })

    assert_equal "ruby", result[:active_language]
  end

  def test_route_prompt_without_a_file_has_no_active_language
    result = @server.call_tool("route_prompt", { "prompt" => "add a migration" })

    assert_nil result[:active_language]
  end

  def test_get_skill_returns_text_and_unknown_raises
    skill = @server.call_tool("get_skill", { "name" => "rails-node-integration" })

    assert_match(/^name: rails-node-integration$/, skill[:text])
    assert_equal "skills/rails-node-integration/SKILL.md", skill[:path]
    assert_raises(RubyAgentSkills::MCP::ToolError) do
      @server.call_tool("get_skill", { "name" => "no-such-skill" })
    end
  end

  def test_list_companions_declares_the_v3_contract
    result = @server.call_tool("list_companions", {})

    packs = result[:companions].map { |companion| companion["pack"] }
    assert_includes packs, "node-agent-skills"
    assert_includes packs, "react-agent-skills"
    boundaries = result[:seam_contracts].map { |contract| contract["boundary"] }
    assert_includes boundaries, "rails-to-node-backend"
    assert_includes boundaries, "rails-to-react-client"
  end

  def test_route_cross_pack_routes_this_pack_first
    result = @server.call_tool("route_cross_pack", { "prompt" => "add a migration with an index" })

    # Companion discovery may find sibling checkouts in a developer clone, so
    # assert on THIS pack's presence and shape rather than an exact count.
    refute_empty result[:packs]
    assert_equal "ruby-agent-skills", result[:packs].first[:pack][:name]
    refute_nil result[:primary]
    assert result[:seam].is_a?(Hash)
    assert_includes [true, false], result[:seam][:recommended]
  end

  def test_validator_executes_this_system_test
    validate = File.read(File.join(ROOT, "bin", "validate"))

    assert_includes validate, "test/mcp_server_system_test.rb"
  end
end
