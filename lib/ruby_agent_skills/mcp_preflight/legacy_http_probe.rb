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
        response = @transport.post(
          "initialize",
          {
            "protocolVersion" => LEGACY_PROTOCOL,
            "capabilities" => {},
            "clientInfo" => CLIENT_INFO
          },
          2,
          modern: false
        )
        validate_initialize_result(result_or_raise(response, "initialize"))
      end

      def validate_initialize_result(result)
        unless result["protocolVersion"] == LEGACY_PROTOCOL
          raise Error.new(
            "protocol_incompatible",
            "legacy HTTP server did not negotiate the requested version"
          )
        end
        return result if result["capabilities"].is_a?(Hash)

        raise Error.new(
          "invalid_initialize",
          "legacy HTTP initialize response has no capabilities object"
        )
      end

      def legacy_tools_supported?(result)
        result.fetch("capabilities", {}).key?("tools")
      end

      def collect_tools
        ToolInventory.collect do |cursor, page|
          params = cursor ? { "cursor" => cursor } : {}
          response = @transport.post("tools/list", params, page + 2, modern: false)
          result_or_raise(response, "tools/list")
        end
      end

      def result_or_raise(response, method)
        raise Error.new("request_failed", "#{method} failed with a JSON-RPC error") if response[:error]

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
