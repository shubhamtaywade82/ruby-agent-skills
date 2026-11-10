# frozen_string_literal: true

require "net/http"
require "openssl"
require "uri"

module RubyAgentSkills
  module MCPPreflight
    class StreamableHttpProbe
      LOOPBACK_HOSTS = %w[localhost 127.0.0.1 ::1].freeze
      MAX_HTTP_RESPONSE_BYTES = 1_048_576
      ResponseData = Struct.new(:code, :body, :headers) do
        def [](name)
          headers[name.downcase]
        end
      end

      def initialize(server_config, timeout:)
        @uri = URI.parse(server_config.fetch("url"))
        @timeout = timeout
      rescue URI::InvalidURIError, KeyError, TypeError
        raise Error.new("invalid_server_config", "HTTP MCP server requires a valid url")
      end

      def call
        validate_url!
        discovery = post("server/discover", { "_meta" => CLIENT_META }, 1, modern: true)
        return legacy_probe if method_not_found?(discovery)

        result = result_or_raise(discovery, "server/discover")
        negotiated = DiscoveryResult.new(result)
        return legacy_probe unless negotiated.modern?
        return report(MODERN_PROTOCOL, negotiated.server_info, []) unless negotiated.supports_tools?

        tools = collect_tools({ "_meta" => CLIENT_META }, 2, modern: true)
        report(MODERN_PROTOCOL, negotiated.server_info, tools)
      end

      private

      def legacy_probe
        initialized = post(
          "initialize",
          {
            "protocolVersion" => LEGACY_PROTOCOL,
            "capabilities" => {},
            "clientInfo" => CLIENT_INFO
          },
          2,
          modern: false
        )
        result = result_or_raise(initialized, "initialize")
        unless result["protocolVersion"] == LEGACY_PROTOCOL
          raise Error.new("protocol_incompatible", "legacy HTTP server did not negotiate the requested version")
        end
        unless result["capabilities"].is_a?(Hash)
          raise Error.new("invalid_initialize", "legacy HTTP initialize response has no capabilities object")
        end

        notify_initialized
        return report(LEGACY_PROTOCOL, HttpResponse.server_info(result["serverInfo"]), []) unless legacy_tools_supported?(result)

        tools = collect_tools({}, 3, modern: false)
        report(LEGACY_PROTOCOL, HttpResponse.server_info(result["serverInfo"]), tools)
      end

      def collect_tools(params, request_id, modern:)
        ToolInventory.collect do |cursor, page|
          page_params = cursor ? params.merge("cursor" => cursor) : params
          response = post("tools/list", page_params, request_id + page - 1, modern: modern)
          result_or_raise(response, "tools/list")
        end
      end

      def result_or_raise(response, method)
        if response[:error]
          raise Error.new("request_failed", "#{method} failed with a JSON-RPC error")
        end

        result = response[:result]
        unless result.is_a?(Hash)
          raise Error.new("invalid_response", "#{method} result must be an object")
        end

        result
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

      def legacy_tools_supported?(result)
        result.fetch("capabilities", {}).key?("tools")
      end

      def method_not_found?(response)
        response[:error].is_a?(Hash) && response[:error]["code"] == -32_601
      end

      def notify_initialized
        request = request_for(
          "notifications/initialized",
          {},
          nil,
          modern: false
        )
        response = perform_request(request)
        ensure_success!(response)
      end

      def validate_url!
        loopback = LOOPBACK_HOSTS.include?(@uri.host)
        secure = @uri.is_a?(URI::HTTPS)
        local_http = @uri.is_a?(URI::HTTP) && loopback
        raise Error.new("unsafe_url", "remote MCP URLs must use HTTPS") unless secure || local_http
        if @uri.user || @uri.password
          raise Error.new("unsafe_url", "MCP URL must not contain credentials")
        end
        raise Error.new("unsafe_url", "MCP URL must not contain a fragment") if @uri.fragment
        raise Error.new("invalid_server_config", "MCP URL must include a host") unless @uri.host
      end

      def post(method, params, id, modern:)
        request = request_for(method, params, id, modern: modern)
        response = perform_request(request)
        if response.code.to_i.between?(200, 299)
          return HttpResponse.parse(response)
        end
        if [401, 403].include?(response.code.to_i)
          raise Error.new("authorization_required", "HTTP MCP server requires authorization")
        end
        if method == "server/discover" && [404, 405, 501].include?(response.code.to_i)
          return { error: { "code" => -32_601 } }
        end

        raise Error.new("http_unavailable", "HTTP MCP server returned status #{response.code}")
      end

      def request_for(method, params, id, modern:)
        request = Net::HTTP::Post.new(@uri)
        request["Content-Type"] = "application/json"
        request["Accept"] = "application/json, text/event-stream"
        request["MCP-Protocol-Version"] = modern ? MODERN_PROTOCOL : LEGACY_PROTOCOL
        request["Mcp-Method"] = method if modern
        payload = { "jsonrpc" => "2.0", "method" => method, "params" => params }
        payload["id"] = id unless id.nil?
        request.body = JSON.generate(payload)
        request
      end

      def ensure_success!(response)
        return if response.code.to_i.between?(200, 299)
        if [401, 403].include?(response.code.to_i)
          raise Error.new("authorization_required", "HTTP MCP server requires authorization")
        end

        raise Error.new("http_unavailable", "HTTP MCP notification returned status #{response.code}")
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
        ) do |http|
          http.request(request) do |response|
            body = +""
            response.read_body do |chunk|
              body << chunk
              if body.bytesize > MAX_HTTP_RESPONSE_BYTES
                raise Error.new("response_too_large", "HTTP MCP response exceeded the 1 MiB limit")
              end
            end
            ResponseData.new(
              response.code,
              body,
              { "content-type" => response["content-type"] }
            )
          end
        end
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
