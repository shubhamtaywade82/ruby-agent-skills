# frozen_string_literal: true

require "json"
require_relative "stdio_tool_list"

module RubyAgentSkills
  module MCPPreflight
    class StdioProtocol
      def initialize(stdin, reader, timeout:)
        @client = StdioClient.new(stdin, reader, timeout: timeout)
      end

      def call
        discovery = discover
        return legacy_initialize if discovery[:error] && method_not_found?(discovery[:error])

        result = result_or_raise(discovery, "server/discover")
        negotiated = DiscoveryResult.new(result)
        return legacy_initialize unless negotiated.modern?
        unless negotiated.supports_tools?
          return empty_tool_list(MODERN_PROTOCOL, negotiated.server_info)
        end

        list_tools(2, { "_meta" => CLIENT_META }, MODERN_PROTOCOL, negotiated.server_info)
      end

      def legacy_call
        legacy_initialize
      end

      private

      def discover
        @client.request(1, "server/discover", { "_meta" => CLIENT_META })
      rescue Error => e
        raise unless %w[timeout server_exited].include?(e.code)

        raise Error.new("legacy_probe_required", e.message)
      end

      def method_not_found?(error)
        error.is_a?(Hash) && error["code"] == -32_601
      end

      def legacy_initialize
        result = legacy_initialize_result
        @client.notify_initialized
        unless legacy_tools_supported?(result)
          return empty_tool_list(LEGACY_PROTOCOL, result["serverInfo"])
        end

        list_tools(3, {}, LEGACY_PROTOCOL, result["serverInfo"])
      end

      def legacy_initialize_result
        response = @client.request(
          2,
          "initialize",
          {
            "protocolVersion" => LEGACY_PROTOCOL,
            "capabilities" => {},
            "clientInfo" => CLIENT_INFO
          }
        )
        validate_legacy_initialize!(result_or_raise(response, "initialize"))
      end

      def validate_legacy_initialize!(result)
        unless result["protocolVersion"] == LEGACY_PROTOCOL
          raise Error.new(
            "protocol_incompatible",
            "legacy server did not negotiate the requested protocol version"
          )
        end
        return result if result["capabilities"].is_a?(Hash)

        message = "legacy initialize response has no capabilities object"
        raise Error.new("invalid_initialize", message)
      end

      def legacy_tools_supported?(result)
        result.fetch("capabilities", {}).key?("tools")
      end

      def empty_tool_list(version, server_info)
        StdioToolList.build({ "tools" => [] }, version, server_info: server_info)
      end

      def list_tools(id, params, version, server_info)
        tools = ToolInventory.collect do |cursor, page|
          page_params = cursor ? params.merge("cursor" => cursor) : params
          listed = @client.request(id + page - 1, "tools/list", page_params)
          result_or_raise(listed, "tools/list")
        end
        StdioToolList.build({ "tools" => tools }, version, server_info: server_info)
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
