# frozen_string_literal: true

require "net/http"
require "openssl"
require "uri"

module RubyAgentSkills
  module MCPPreflight
    class StreamableHttpProbe
      LOOPBACK_HOSTS = %w[localhost 127.0.0.1 ::1].freeze

      def initialize(server_config, timeout:)
        @uri = URI.parse(server_config.fetch("url"))
        @timeout = timeout
      rescue URI::InvalidURIError, KeyError, TypeError
        raise Error.new("invalid_server_config", "HTTP MCP server requires a valid url")
      end

      def call
        validate_url!
        discovery = post("server/discover", { "_meta" => CLIENT_META }, 1)
        if discovery[:error]
          raise Error.new("protocol_incompatible", "HTTP server does not support modern server/discover")
        end

        result = discovery[:result]
        raise Error.new("invalid_discovery", "server/discover result must be an object") unless result.is_a?(Hash)
        listed = post("tools/list", { "_meta" => CLIENT_META }, 2)
        tools = HttpResponse.tools(listed[:result] || {})

        {
          status: "healthy",
          transport: "streamable_http",
          protocol_version: MODERN_PROTOCOL,
          server_info: HttpResponse.server_info(result["serverInfo"]),
          tools: tools,
          checked_at: Time.now.utc.iso8601
        }
      end

      private

      def validate_url!
        loopback = LOOPBACK_HOSTS.include?(@uri.host)
        secure = @uri.is_a?(URI::HTTPS)
        local_http = @uri.is_a?(URI::HTTP) && loopback
        raise Error.new("unsafe_url", "remote MCP URLs must use HTTPS") unless secure || local_http
        raise Error.new("unsafe_url", "MCP URL must not contain credentials") if @uri.user || @uri.password
        raise Error.new("unsafe_url", "MCP URL must not contain a fragment") if @uri.fragment
        raise Error.new("invalid_server_config", "MCP URL must include a host") unless @uri.host
      end

      def post(method, params, id)
        request = request_for(method, params, id)
        response = perform_request(request)
        return HttpResponse.parse(response) if response.code.to_i.between?(200, 299)
        raise Error.new("authorization_required", "HTTP MCP server requires authorization") if [401, 403].include?(response.code.to_i)

        raise Error.new("http_unavailable", "HTTP MCP server returned status #{response.code}")
      end

      def request_for(method, params, id)
        request = Net::HTTP::Post.new(@uri)
        request["Content-Type"] = "application/json"
        request["Accept"] = "application/json, text/event-stream"
        request["MCP-Protocol-Version"] = MODERN_PROTOCOL
        request["Mcp-Method"] = method
        request.body = JSON.generate(
          "jsonrpc" => "2.0",
          "id" => id,
          "method" => method,
          "params" => params
        )
        request
      end

      def perform_request(request)
        Net::HTTP.start(
          @uri.host,
          @uri.port,
          use_ssl: @uri.is_a?(URI::HTTPS),
          open_timeout: @timeout,
          read_timeout: @timeout,
          write_timeout: @timeout,
          verify_mode: OpenSSL::SSL::VERIFY_PEER
        ) { |http| http.request(request) }
      rescue Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout
        raise Error.new("timeout", "timed out waiting for HTTP MCP server")
      rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        raise Error.new("unavailable", "HTTP MCP server could not be reached")
      rescue OpenSSL::SSL::SSLError
        raise Error.new("tls_error", "HTTP MCP TLS verification failed")
      end
    end
  end
end
