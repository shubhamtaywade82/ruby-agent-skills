# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "rbconfig"
require "tmpdir"
require_relative "../../lib/ruby_agent_skills/mcp_preflight"

class McpPreflightTestCase < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  POLICY = File.join(ROOT, "mcp", "permissions.yml")

  def setup
    @tmpdir = Dir.mktmpdir("mcp-preflight")
  end

  def teardown
    FileUtils.remove_entry(@tmpdir) if File.directory?(@tmpdir)
  end

  private

  def run_preflight(options)
    config_path = File.join(@tmpdir, "mcp.json")
    counter_path = File.join(@tmpdir, "probe-count")
    registration = fake_registration(options, counter_path)
    write_client_config(config_path, options.fetch(:server), registration, options)
    RubyAgentSkills::MCPPreflight::Runner.new(runner_options(options, config_path)).call
  end

  def fake_registration(options, counter_path)
    {
      "command" => RbConfig.ruby,
      "args" => [File.join(ROOT, "test", "fixtures", "mcp_preflight_fake_server.rb")],
      "env" => {
        "MCP_PREFLIGHT_CALLS" => counter_path,
        "MCP_PREFLIGHT_FAKE_SERVER_OPTIONS" => JSON.generate(fake_options(options))
      }
    }
  end

  def fake_options(options)
    keys = %i[
      modern exit_early supported_versions supports_tools tool_pages
      silence_first_discovery tools
    ]
    keys.each_with_object({}) do |key, result|
      result[key.to_s] = options[key] if options.key?(key)
    end
  end

  def write_client_config(path, server, registration, options)
    servers = options[:omit_server_config] ? {} : { server => registration }
    File.write(path, JSON.generate("mcpServers" => servers), encoding: "UTF-8")
  end

  def runner_options(options, config_path)
    {
      config_path: config_path,
      policy_path: POLICY,
      server: options.fetch(:server),
      tool: options.fetch(:tool),
      profile: options.fetch(:profile, "inspect"),
      environment: options.fetch(:environment, "development"),
      isolated: options.fetch(:isolated, false),
      timeout: 2,
      probe: options.fetch(:probe, true)
    }
  end

  def assert_modern_probe_result(result)
    assert_equal "healthy", result.dig(:health, :status)
    assert result.dig(:health, :configured)
    assert_equal "2026-07-28", result.dig(:health, :protocol_version)
    assert_equal "test-server", result.dig(:health, :server_info, :name)
    assert_includes result.dig(:health, :tools), "schema_graph"
    assert_equal "allowed", result[:decision]
    refute result[:tool_invoked]
  end

  def write_hard_deny_policy(path)
    fixture = File.join(ROOT, "test", "fixtures", "mcp_preflight_hard_deny.yml")
    FileUtils.cp(fixture, path)
  end

  def http_probe(url)
    RubyAgentSkills::MCPPreflight::StreamableHttpProbe.new({ "url" => url }, timeout: 1)
  end
end
