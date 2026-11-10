# frozen_string_literal: true

module RubyAgentSkills
  module MCPPreflight
    class Runner
      def initialize(config_path:, policy_path:, server:, tool:, profile:, environment:,
                     isolated:, cwd: nil,
                     timeout: DEFAULT_TIMEOUT, probe: false)
        @server = server
        @tool = tool
        @profile = profile
        @environment = environment
        @isolated = isolated
        @policy = Policy.new(policy_path)
        @probe = probe
        @server_probe = ServerProbe.new(
          config_path: config_path,
          server: server,
          cwd: cwd,
          timeout: timeout
        )
      end

      def call
        permission = permission_decision
        return report(not_checked, permission) if permission[:decision] == "denied"
        unless @probe
          message = "pass --probe to start or contact the MCP server"
          raise Error.new("probe_confirmation_required", message)
        end

        health = @server_probe.call
        return report(health, unavailable(health)) unless health[:status] == "healthy"
        return report(health, missing_tool) unless health[:tools].include?(@tool)

        report(health, permission)
      end

      private

      def permission_decision
        @policy.evaluate(
          server: @server,
          tool: @tool,
          profile: @profile,
          environment: @environment,
          isolated: @isolated
        )
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

      def missing_tool
        {
          decision: "unavailable",
          reason: "requested tool is absent from the live tools/list response"
        }
      end

      def report(health, permission)
        {
          schema_version: 1,
          server: @server,
          tool: @tool,
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
