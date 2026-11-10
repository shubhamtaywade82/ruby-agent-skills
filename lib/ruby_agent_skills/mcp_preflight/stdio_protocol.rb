# frozen_string_literal: true

require "json"
require_relative "stdio_tool_list"

module RubyAgentSkills
  module MCPPreflight
    class StdioProtocol
      def initialize(stdin, reader, timeout:)
        @stdin = stdin
        @reader = reader
        @timeout = timeout
      end

      def call
        discovery = request(1, "server/discover", { "_meta" => CLIENT_META })
        if discovery[:error]
          return legacy_initialize if discovery[:error]["code"] == -32_601

          raise Error.new("discovery_failed", "MCP server discovery failed: #{error_code(discovery[:error])}")
        end

        result = result_or_raise(discovery, "server/discover")
        listed = request(2, "tools/list", { "_meta" => CLIENT_META })
        StdioToolList.build(result_or_raise(listed, "tools/list"), MODERN_PROTOCOL)
      end

      private

      def legacy_initialize
        initialized = request(
          2,
          "initialize",
          {
            "protocolVersion" => LEGACY_PROTOCOL,
            "capabilities" => {},
            "clientInfo" => CLIENT_INFO
          }
        )
        result = result_or_raise(initialized, "initialize")
        version = result["protocolVersion"]
        unless version.is_a?(String)
          raise Error.new("invalid_initialize", "legacy initialize response has no protocolVersion")
        end

        notify_initialized
        listed = request(3, "tools/list", {})
        StdioToolList.build(result_or_raise(listed, "tools/list"), version)
      end

      def notify_initialized
        notification = {
          "jsonrpc" => "2.0",
          "method" => "notifications/initialized",
          "params" => {}
        }
        @stdin.write(JSON.generate(notification))
        @stdin.write("\n")
        @stdin.flush
      end

      def request(id, method, params)
        message = { "jsonrpc" => "2.0", "id" => id, "method" => method, "params" => params }
        @stdin.write(JSON.generate(message))
        @stdin.write("\n")
        @stdin.flush
        @reader.response_for(id, timeout: @timeout)
      rescue IOError, Errno::EPIPE
        raise Error.new("server_exited", "MCP server closed STDIN before responding")
      end

      def result_or_raise(response, method)
        raise Error.new("request_failed", "#{method} failed: #{error_code(response[:error])}") if response[:error]

        result = response[:result]
        raise Error.new("invalid_response", "#{method} result must be an object") unless result.is_a?(Hash)

        result
      end

      def error_code(error)
        error.is_a?(Hash) ? error["code"].to_s : "unknown"
      end
    end
  end
end
