# frozen_string_literal: true

module RubyAgentSkills
  module MCPPreflight
    class LegacyHttpProbe
      def initialize(transport)
        @transport = transport
      end

      def call
        result = initialize_server
        @transport.notify_initialized
        tools = legacy_tools_supported?(result) ? collect_tools : []
        report(result, tools)
      end

      private

      def initialize_server
        response = @transport.post("initialize", initialize_params, 2, modern: false)
        validate_initialize_result(result_or_raise(response, "initialize"))
      end

      def initialize_params
        {
          "protocolVersion" => LEGACY_PROTOCOL,
          "capabilities" => {},
          "clientInfo" => CLIENT_INFO
        }
      end

      def validate_initialize_result(result)
        validate_protocol_version!(result)
        validate_capabilities!(result)
        result
      end

      def validate_protocol_version!(result)
        return if result["protocolVersion"] == LEGACY_PROTOCOL

        raise Error.new(
          "protocol_incompatible",
          "legacy HTTP server did not negotiate the requested version"
        )
      end

      def validate_capabilities!(result)
        return if result["capabilities"].is_a?(Hash)

        raise Error.new(
          "invalid_initialize",
          "legacy HTTP initialize response has no capabilities object"
        )
      end

      def legacy_tools_supported?(result)
        result.fetch("capabilities", {}).key?("tools")
      end

      def collect_tools
        tools = ToolInventory.collect do |cursor, page|
          params = cursor ? { "cursor" => cursor } : {}
          response = @transport.post("tools/list", params, page + 2, modern: false)
          result_or_raise(response, "tools/list")
        end
        tools.map { |tool| tool.fetch("name") }.sort
      end

      def result_or_raise(response, method)
        if response[:error]
          raise Error.new("request_failed", "#{method} failed with a JSON-RPC error")
        end

        result = response[:result]
        return result if result.is_a?(Hash)

        raise Error.new("invalid_response", "#{method} result must be an object")
      end

      def report(result, tools)
        {
          status: "healthy",
          configured: true,
          transport: "streamable_http",
          protocol_version: LEGACY_PROTOCOL,
          server_info: HttpResponse.server_info(result["serverInfo"]),
          tools: tools,
          checked_at: Time.now.utc.iso8601
        }
      end
    end
  end
end
