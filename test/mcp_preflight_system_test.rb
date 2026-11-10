# frozen_string_literal: true

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
      server: "rails",
      tool: "schema_graph",
      tools: %w[schema_graph run_tests],
      profile: "inspect"
    )

    assert_equal "healthy", result.dig(:health, :status)
    assert_equal "2026-07-28", result.dig(:health, :protocol_version)
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

  def test_unclassified_tool_is_denied_even_when_discovered
    result = run_preflight(
      server: "ask-rails-harness",
      tool: "new_sensitive_tool",
      tools: %w[new_sensitive_tool]
    )

    assert_equal "denied", result[:decision]
    assert_match(/unclassified/, result[:reason])
  end

  def test_tool_missing_from_live_tools_list_is_unavailable
    result = run_preflight(
      server: "rails",
      tool: "tool_that_does_not_exist",
      tools: %w[schema_graph]
    )

    assert_equal "unavailable", result[:decision]
    assert_equal "healthy", result.dig(:health, :status)
  end

  def test_production_is_denied_even_for_read_only_capabilities
    result = run_preflight(
      server: "rails",
      tool: "schema_graph",
      tools: %w[schema_graph],
      environment: "production"
    )

    assert_equal "denied", result[:decision]
    assert_match(/production environment/, result[:reason])
  end

  def test_preflight_requires_explicit_confirmation_before_starting_a_server
    error = assert_raises(RubyAgentSkills::MCPPreflight::Error) do
      run_preflight(
        server: "rails",
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
    policy = RubyAgentSkills::MCPPreflight::Policy.new(POLICY)

    %w[production_access credential_export].each do |capability|
      result = policy.evaluate(
        server: "example",
        tool: "sensitive",
        profile: "maintenance",
        environment: "development",
        isolated: true
      )
      refute_equal "allowed", result[:decision], capability
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

  def test_validator_executes_this_system_test
    validate = File.read(File.join(ROOT, "bin", "validate"), encoding: "UTF-8")

    assert_includes validate, "test/mcp_preflight_system_test.rb"
  end

  private

  def run_preflight(server:, tool:, tools:, profile: "inspect", environment: "development",
                    isolated: false, modern: true, probe: true)
    config_path = File.join(@tmpdir, "mcp.json")
    File.write(
      config_path,
      JSON.generate(
        "mcpServers" => {
          server => {
            "command" => RbConfig.ruby,
            "args" => ["-e", fake_server(modern: modern, tools: tools)]
          }
        }
      ),
      encoding: "UTF-8"
    )

    runner = RubyAgentSkills::MCPPreflight::Runner.new(
      config_path: config_path,
      policy_path: POLICY,
      server: server,
      tool: tool,
      profile: profile,
      environment: environment,
      isolated: isolated,
      timeout: 2,
      probe: probe
    )
    runner.call
  end

  def fake_server(modern:, tools:)
    <<~RUBY
      require "json"
      modern = #{modern}
      tools = #{tools.inspect}

      STDIN.each_line do |line|
        request = JSON.parse(line)
        method = request["method"]
        response =
          case method
          when "server/discover"
            if modern
              {
                "jsonrpc" => "2.0",
                "id" => request["id"],
                "result" => {
                  "protocolVersion" => "2026-07-28",
                  "serverInfo" => { "name" => "test-server", "version" => "1.0" }
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
            {
              "jsonrpc" => "2.0",
              "id" => request["id"],
              "result" => { "tools" => tools.map { |name| { "name" => name } } }
            }
          end

        STDOUT.write(JSON.generate(response))
        STDOUT.write("\\n")
        STDOUT.flush
      end
    RUBY
  end
end
