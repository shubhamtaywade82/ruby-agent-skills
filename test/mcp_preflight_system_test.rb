# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "rbconfig"
require "tmpdir"
require_relative "../lib/ruby_agent_skills/mcp_preflight"

class McpPreflightSystemTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  POLICY = File.join(ROOT, "mcp", "permissions.yml")

  def setup
    @tmpdir = Dir.mktmpdir("mcp-preflight")
  end

  def teardown
    FileUtils.remove_entry(@tmpdir) if File.directory?(@tmpdir)
  end

  def test_modern_stdio_discovery_lists_the_live_tool_and_allows_inspection
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "schema_graph",
      tools: %w[schema_graph run_tests],
      profile: "inspect"
    )

    assert_equal "healthy", result.dig(:health, :status)
    assert_equal true, result.dig(:health, :configured)
    assert_equal "2026-07-28", result.dig(:health, :protocol_version)
    assert_equal "test-server", result.dig(:health, :server_info, :name)
    assert_includes result.dig(:health, :tools), "schema_graph"
    assert_equal "allowed", result[:decision]
    refute result[:tool_invoked]
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

  private

  def run_preflight(options)
    server = options.fetch(:server)
    tool = options.fetch(:tool)
    tools = options.fetch(:tools)
    profile = options.fetch(:profile, "inspect")
    environment = options.fetch(:environment, "development")
    isolated = options.fetch(:isolated, false)
    modern = options.fetch(:modern, true)
    probe = options.fetch(:probe, true)
    exit_early = options.fetch(:exit_early, false)
    omit_server_config = options.fetch(:omit_server_config, false)
    supported_versions = options.fetch(:supported_versions, ["2026-07-28"])
    supports_tools = options.fetch(:supports_tools, true)
    tool_pages = options.fetch(:tool_pages, [tools])
    silence_first_discovery = options.fetch(:silence_first_discovery, false)
    counter_path = File.join(@tmpdir, "probe-count")
    config_path = File.join(@tmpdir, "mcp.json")
    registration = {
      "command" => RbConfig.ruby,
      "args" => [
        "-e",
        fake_server(
          modern: modern,
          tools: tools,
          exit_early: exit_early,
          supported_versions: supported_versions,
          supports_tools: supports_tools,
          tool_pages: tool_pages,
          silence_first_discovery: silence_first_discovery,
          counter_path: counter_path
        )
      ],
      "env" => { "MCP_PREFLIGHT_CALLS" => counter_path }
    }
    File.write(
      config_path,
      JSON.generate("mcpServers" => (omit_server_config ? {} : { server => registration })),
      encoding: "UTF-8"
    )

    runner_options = {
      config_path: config_path,
      policy_path: POLICY,
      server: server,
      tool: tool,
      profile: profile,
      environment: environment,
      isolated: isolated,
      timeout: 2,
      probe: probe
    }
    RubyAgentSkills::MCPPreflight::Runner.new(runner_options).call
  end

  def fake_server(modern:, tools:, exit_early:, supported_versions:,
                  supports_tools:, tool_pages:, silence_first_discovery:, counter_path:)
    <<~RUBY
      require "json"
      modern = #{modern}
      exit_early = #{exit_early}
      supported_versions = #{supported_versions.inspect}
      supports_tools = #{supports_tools}
      tool_pages = #{tool_pages.inspect}
      silence_first_discovery = #{silence_first_discovery}
      counter_path = ENV.fetch("MCP_PREFLIGHT_CALLS")
      calls = File.exist?(counter_path) ? File.read(counter_path).to_i : 0
      File.write(counter_path, (calls + 1).to_s)
      tools = #{tools.inspect}

      if silence_first_discovery && calls.zero?
        STDIN.readline
        sleep 60
      end

      STDIN.each_line do |line|
        exit 0 if exit_early

        request = JSON.parse(line)
        method = request["method"]
        response =
          case method
          when "server/discover"
            if modern
              capabilities = supports_tools ? { "tools" => {} } : {}
              {
                "jsonrpc" => "2.0",
                "id" => request["id"],
                "result" => {
                  "resultType" => "complete",
                  "supportedVersions" => supported_versions,
                  "capabilities" => capabilities,
                  "cacheScope" => "public",
                  "ttlMs" => 30_000,
                  "_meta" => {
                    "io.modelcontextprotocol/serverInfo" => {
                      "name" => "test-server", "version" => "1.0"
                    }
                  }
                }
              }
            else
              {
                "jsonrpc" => "2.0",
                "id" => request["id"],
                "error" => { "code" => -32601, "message" => "Method not found" }
              }
            end
          when "initialize"
            {
              "jsonrpc" => "2.0",
              "id" => request["id"],
              "result" => {
                "protocolVersion" => "2025-11-25",
                "capabilities" => { "tools" => {} },
                "serverInfo" => { "name" => "legacy-test-server", "version" => "1.0" }
              }
            }
          when "notifications/initialized"
            next
          when "tools/list"
            cursor = request.dig("params", "cursor")
            page_index = cursor ? cursor.to_i : 0
            next_cursor = (page_index + 1).to_s if page_index + 1 < tool_pages.length
            page = tool_pages.fetch(page_index)
            tools_result = { "tools" => page.map { |name| { "name" => name } } }
            tools_result["nextCursor"] = next_cursor if next_cursor
            {
              "jsonrpc" => "2.0",
              "id" => request["id"],
              "result" => tools_result
            }
          end

        STDOUT.write(JSON.generate(response))
        STDOUT.write("\n")
        STDOUT.flush
      end
    RUBY
  end
end
