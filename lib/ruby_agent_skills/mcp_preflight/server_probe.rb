# frozen_string_literal: true

require "json"

module RubyAgentSkills
  module MCPPreflight
    class ServerProbe
      def initialize(config_path:, server:, cwd:, timeout:)
        @config_path = config_path
        @server = server
        @cwd = cwd
        @timeout = timeout
      end

      def call
        probe(load_server_config)
      rescue JSON::ParserError => e
        raise Error.new("invalid_client_config", "MCP client config is not valid JSON: #{e.message}")
      end

      private

      def load_server_config
        configuration = JSON.parse(File.read(@config_path, encoding: "UTF-8"))
        server_config = configuration.fetch("mcpServers").fetch(@server) do
          raise Error.new("server_not_configured", "MCP server #{@server} is not registered")
        end
        raise Error.new("invalid_server_config", "server registration must be a mapping") unless server_config.is_a?(Hash)

        server_config
      rescue KeyError => e
        raise Error.new("invalid_client_config", "MCP client config is missing #{e.key}")
      end

      def probe(config)
        if config["command"]
          return StdioProbe.new(config, cwd: @cwd, timeout: @timeout).call
        end
        return http_probe(config) if config["url"]

        raise Error.new("unsupported_transport", "server registration requires command or url")
      end

      def http_probe(config)
        if config["headers"]
          raise Error.new("unsupported_http_auth", "preflight does not perform OAuth; authenticate in the MCP host")
        end

        StreamableHttpProbe.new(config, timeout: @timeout).call
      end
    end
  end
end
