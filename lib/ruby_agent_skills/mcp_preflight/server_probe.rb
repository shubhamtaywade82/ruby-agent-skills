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
        config = load_server_config
        probe(config)
      rescue JSON::ParserError => e
        message = "MCP client config is not valid JSON: #{e.message}"
        raise Error.new("invalid_client_config", message)
      rescue Error => e
        health_failure(e)
      end

      private

      def load_server_config
        configuration = JSON.parse(File.read(@config_path, encoding: "UTF-8"))
        server_config = configuration.fetch("mcpServers").fetch(@server) do
          raise Error.new("server_not_configured", "MCP server #{@server} is not registered")
        end
        unless server_config.is_a?(Hash)
          raise Error.new("invalid_server_config", "server registration must be a mapping")
        end

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
          message = "preflight does not perform OAuth; authenticate in the MCP host"
          raise Error.new("unsupported_http_auth", message)
        end

        StreamableHttpProbe.new(config, timeout: @timeout).call
      end

      def health_failure(error)
        status = error.code == "authorization_required" ? "authorization_required" : "unavailable"
        transport = error.code.to_s.start_with?("http", "unsafe", "tls") ? "streamable_http" : "stdio"
        {
          status: status,
          transport: transport,
          reason: "#{error.code}: #{error.message}",
          tools: [],
          checked_at: Time.now.utc.iso8601
        }
      end
    end
  end
end
