# frozen_string_literal: true

require "json"

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
        normalize_tools(result_or_raise(listed, "tools/list"), MODERN_PROTOCOL, result["serverInfo"])
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
        normalize_tools(result_or_raise(listed, "tools/list"), version, result["serverInfo"])
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

      def normalize_tools(result, version, server_info)
        tools = result["tools"]
        valid = tools.is_a?(Array) && tools.all? { |tool| tool.is_a?(Hash) && tool["name"].is_a?(String) }
        raise Error.new("invalid_tools_list", "tools/list response must contain named tools") unless valid

        {
          protocol_version: version,
          server_info: safe_server_info(server_info),
          tools: tools.map { |tool| tool["name"] }.uniq.sort
        }
      end

      def safe_server_info(info)
        return nil unless info.is_a?(Hash)

        { name: info["name"], version: info["version"] }
      end

      def error_code(error)
        error.is_a?(Hash) ? error["code"].to_s : "unknown"
      end
    end
  end
end
