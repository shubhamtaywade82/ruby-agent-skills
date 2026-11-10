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
        discovery = discover
        return legacy_initialize if discovery[:error] && method_not_found?(discovery[:error])

        result = result_or_raise(discovery, "server/discover")
        negotiated = DiscoveryResult.new(result)
        return legacy_initialize unless negotiated.modern?

        list_tools(2, { "_meta" => CLIENT_META }, MODERN_PROTOCOL, negotiated.server_info)
      end

      def legacy_call
        legacy_initialize
      end

      private

      def discover
        request(1, "server/discover", { "_meta" => CLIENT_META })
      rescue Error => e
        raise unless %w[timeout server_exited].include?(e.code)

        raise Error.new("legacy_probe_required", e.message)
      end

      def method_not_found?(error)
        error.is_a?(Hash) && error["code"] == -32_601
      end

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
        unless result["protocolVersion"] == LEGACY_PROTOCOL
          raise Error.new("protocol_incompatible", "legacy server did not negotiate the requested protocol version")
        end

        notify_initialized
        list_tools(3, {}, LEGACY_PROTOCOL, result["serverInfo"])
      end

      def list_tools(id, params, version, server_info)
        listed = request(id, "tools/list", params)
        StdioToolList.build(
          result_or_raise(listed, "tools/list"),
          version,
          server_info: server_info
        )
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
        if response[:error]
          raise Error.new("request_failed", "#{method} failed: #{error_code(response[:error])}")
        end

        result = response[:result]
        unless result.is_a?(Hash)
          raise Error.new("invalid_response", "#{method} result must be an object")
        end

        result
      end

      def error_code(error)
        error.is_a?(Hash) ? error["code"].to_s : "unknown"
      end
    end
  end
end
