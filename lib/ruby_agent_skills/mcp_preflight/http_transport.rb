# frozen_string_literal: true

require "json"
require "net/http"
require "openssl"

module RubyAgentSkills
  module MCPPreflight
    class HttpTransport
      MAX_RESPONSE_BYTES = 1_048_576
      ResponseData = Struct.new(:code, :body, :headers) do
        def [](name)
          headers[name.downcase]
        end
      end

      def initialize(uri, timeout:)
        @uri = uri
        @timeout = timeout
      end

      def post(method, params, id, modern:)
        response = perform_request(request_for(method, params, id, modern))
        return HttpResponse.parse(response) if successful?(response)

        raise_authorization_error(response) if unauthorized?(response)
        return method_not_found if discovery_not_supported?(method, response)

        raise_http_error(response)
      end

      def notify_initialized
        request = request_for("notifications/initialized", {}, nil, false)
        response = perform_request(request)
        ensure_success!(response)
      end

      private

      def request_for(method, params, id, modern)
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

      def perform_request(request)
        Net::HTTP.start(
          @uri.hostname,
          @uri.port,
          use_ssl: @uri.is_a?(URI::HTTPS),
          open_timeout: @timeout,
          read_timeout: @timeout,
          write_timeout: @timeout,
          verify_mode: OpenSSL::SSL::VERIFY_PEER
        ) do |http|
          http.request(request) { |response| response_data(response) }
        end
      rescue Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout
        raise Error.new("timeout", "timed out waiting for HTTP MCP server")
      rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        raise Error.new("unavailable", "HTTP MCP server could not be reached")
      rescue OpenSSL::SSL::SSLError
        raise Error.new("tls_error", "HTTP MCP TLS verification failed")
      end

      def response_data(response)
        body = read_response_body(response)
        ResponseData.new(
          response.code,
          body,
          { "content-type" => response["content-type"] }
        )
      end

      def read_response_body(response)
        body = +""
        response.read_body do |chunk|
          body << chunk
          enforce_response_limit!(body)
        end
        body
      end

      def enforce_response_limit!(body)
        return unless body.bytesize > MAX_RESPONSE_BYTES

        raise Error.new("response_too_large", "HTTP MCP response exceeded the 1 MiB limit")
      end

      def ensure_success!(response)
        return if successful?(response)

        raise_authorization_error(response) if unauthorized?(response)
        message = "HTTP MCP notification returned status #{response.code}"
        raise Error.new("http_unavailable", message)
      end

      def successful?(response)
        response.code.to_i.between?(200, 299)
      end

      def unauthorized?(response)
        [401, 403].include?(response.code.to_i)
      end

      def raise_authorization_error(_response)
        raise Error.new("authorization_required", "HTTP MCP server requires authorization")
      end

      def discovery_not_supported?(method, response)
        method == "server/discover" && [404, 405, 501].include?(response.code.to_i)
      end

      def method_not_found
        { error: { "code" => -32_601 } }
      end

      def raise_http_error(response)
        raise Error.new("http_unavailable", "HTTP MCP server returned status #{response.code}")
      end
    end
  end
end
