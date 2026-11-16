# frozen_string_literal: true

require "uri"
require_relative "http_transport"
require_relative "legacy_http_probe"

module RubyAgentSkills
  module MCPPreflight
    class StreamableHttpProbe
      LOOPBACK_HOSTS = %w[localhost 127.0.0.1 ::1].freeze

      def initialize(server_config, timeout:)
        @uri = URI.parse(server_config.fetch("url"))
        @transport = HttpTransport.new(@uri, timeout: timeout)
      rescue URI::InvalidURIError, KeyError, TypeError
        raise Error.new("invalid_server_config", "HTTP MCP server requires a valid url")
      end

      def call
        validate_url!
        discovery = @transport.post("server/discover", { "_meta" => CLIENT_META }, 1, modern: true)
        return LegacyHttpProbe.new(@transport).call if method_not_found?(discovery)

        result = result_or_raise(discovery, "server/discover")
        negotiated = DiscoveryResult.new(result)
        return LegacyHttpProbe.new(@transport).call unless negotiated.modern?
        return report(MODERN_PROTOCOL, negotiated.server_info, []) unless negotiated.supports_tools?

        tools = collect_tools({ "_meta" => CLIENT_META }, 2)
        report(MODERN_PROTOCOL, negotiated.server_info, tools)
      end

      private

      def collect_tools(params, request_id)
        tools = ToolInventory.collect do |cursor, page|
          page_params = cursor ? params.merge("cursor" => cursor) : params
          response = @transport.post("tools/list", page_params, request_id + page - 1, modern: true)
          result_or_raise(response, "tools/list")
        end
        tools.map { |tool| tool.fetch("name") }
      end

      def result_or_raise(response, method)
        if response[:error]
          raise Error.new("request_failed", "#{method} failed with a JSON-RPC error")
        end

        result = response[:result]
        return result if result.is_a?(Hash)

        raise Error.new("invalid_response", "#{method} result must be an object")
      end

      def report(version, server_info, tools)
        {
          status: "healthy",
          configured: true,
          transport: "streamable_http",
          protocol_version: version,
          server_info: server_info,
          tools: tools,
          checked_at: Time.now.utc.iso8601
        }
      end

      def method_not_found?(response)
        response[:error].is_a?(Hash) && response[:error]["code"] == -32_601
      end

      def validate_url!
        validate_scheme!
        validate_credentials!
        validate_fragment!
        validate_host!
      end

      def validate_scheme!
        secure = @uri.is_a?(URI::HTTPS)
        local_http = @uri.is_a?(URI::HTTP) && LOOPBACK_HOSTS.include?(@uri.hostname)
        return if secure || local_http

        raise Error.new("unsafe_url", "remote MCP URLs must use HTTPS")
      end

      def validate_credentials!
        return unless @uri.user || @uri.password

        raise Error.new("unsafe_url", "MCP URL must not contain credentials")
      end

      def validate_fragment!
        return unless @uri.fragment

        raise Error.new("unsafe_url", "MCP URL must not contain a fragment")
      end

      def validate_host!
        return if @uri.host

        raise Error.new("invalid_server_config", "MCP URL must include a host")
      end
    end
  end
end
