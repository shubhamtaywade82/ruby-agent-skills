# frozen_string_literal: true

require "json"

module RubyAgentSkills
  module MCPPreflight
    class Runner
      def initialize(config_path:, policy_path:, server:, tool:, profile:, environment:, isolated:, cwd: nil,
                     timeout: DEFAULT_TIMEOUT, probe: false)
        @config_path = config_path
        @policy = Policy.new(policy_path)
        @server_name = server
        @tool_name = tool
        @profile = profile
        @environment = environment
        @isolated = isolated
        @cwd = cwd
        @timeout = timeout
        @probe = probe
      end

      def call
        permission = evaluate_permission
        return report(not_checked, permission) if permission[:decision] == "denied"

        unless @probe
          raise Error.new("probe_confirmation_required", "pass --probe to start or contact the MCP server")
        end

        server_config = load_server_config
        health = probe_server(server_config)
        return report(health, unavailable(health)) unless health[:status] == "healthy"

        unless health[:tools].include?(@tool_name)
          reason = "requested tool is absent from the live tools/list response"
          return report(health, { decision: "unavailable", reason: reason })
        end

        report(health, permission)
      rescue JSON::ParserError => e
        raise Error.new("invalid_client_config", "MCP client config is not valid JSON: #{e.message}")
      end

      private

      def evaluate_permission
        @policy.evaluate(
          server: @server_name,
          tool: @tool_name,
          profile: @profile,
          environment: @environment,
          isolated: @isolated
        )
      end

      def load_server_config
        configuration = JSON.parse(File.read(@config_path, encoding: "UTF-8"))
        servers = configuration.fetch("mcpServers")
        server_config = servers.fetch(@server_name) do
          raise Error.new("server_not_configured", "MCP server #{@server_name} is not registered")
        end
        raise Error.new("invalid_server_config", "server registration must be a mapping") unless server_config.is_a?(Hash)

        server_config
      rescue KeyError => e
        raise Error.new("invalid_client_config", "MCP client config is missing #{e.key}")
      end

      def probe_server(config)
        if config["command"]
          StdioProbe.new(config, cwd: @cwd, timeout: @timeout).call
        elsif config["url"]
          raise Error.new("unsupported_http_auth", "preflight does not perform OAuth; authenticate in the MCP host") if config["headers"]

          StreamableHttpProbe.new(config, timeout: @timeout).call
        else
          raise Error.new("unsupported_transport", "server registration requires command or url")
        end
      rescue Error => e
        {
          status: e.code == "authorization_required" ? "authorization_required" : "unavailable",
          transport: config["command"] ? "stdio" : "streamable_http",
          reason: "#{e.code}: #{e.message}",
          tools: [],
          checked_at: Time.now.utc.iso8601
        }
      end

      def not_checked
        {
          status: "not_checked",
          reason: "permission was denied before starting or contacting the MCP server",
          tools: []
        }
      end

      def unavailable(health)
        { decision: "unavailable", reason: health[:reason] || health[:status] }
      end

      def report(health, permission)
        {
          schema_version: 1,
          server: @server_name,
          tool: @tool_name,
          profile: @profile,
          environment: @environment,
          isolated: @isolated,
          health: health,
          decision: permission[:decision],
          capability: permission[:capability],
          reason: permission[:reason],
          tool_invoked: false
        }
      end
    end
  end
end
