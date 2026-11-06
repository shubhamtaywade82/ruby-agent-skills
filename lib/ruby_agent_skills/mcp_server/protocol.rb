# frozen_string_literal: true

# JSON-RPC 2.0 over stdio for the ruby-agent-skills MCP server.

module RubyAgentSkills
  module MCP
    module Protocol
      PARSE_ERROR = -32_700
      INVALID_PARAMS = -32_602
      METHOD_NOT_FOUND = -32_601

      module_function

      def run(server, input: $stdin, output: $stdout)
        input.each_line do |line|
          handle_line(server, line, output)
        end
        0
      end

      def handle_line(server, line, output)
        stripped = line.strip
        return if stripped.empty?

        request = JSON.parse(stripped)
        respond(output, dispatch(server, request))
      rescue JSON::ParserError
        write(output, error_response(nil, PARSE_ERROR, "parse error"))
      rescue ToolError, KeyError => e
        write(output, param_error_response(stripped, e))
      end

      # Notifications (no response) must not be echoed back to the client.
      def respond(output, response)
        write(output, response) unless response.nil?
      end

      def param_error_response(line, error)
        prefix = error.is_a?(KeyError) ? "missing required argument: " : ""
        error_response(request_id(line), INVALID_PARAMS, "#{prefix}#{error.message}")
      end

      def dispatch(server, request)
        case request.fetch("method", "")
        when "initialize" then initialize_response(request["id"])
        when "initialized", "notifications/initialized" then nil
        when "tools/list" then tools_list_response(server, request["id"])
        when "tools/call" then tools_call_response(server, request)
        when "ping" then { jsonrpc: "2.0", id: request["id"], result: {} }
        else error_response(request["id"], METHOD_NOT_FOUND,
                            "method not found: #{request['method']}")
        end
      end

      def initialize_response(request_id)
        {
          jsonrpc: "2.0",
          id: request_id,
          result: {
            protocolVersion: PROTOCOL_VERSION,
            serverInfo: { name: SERVER_NAME, version: SERVER_VERSION },
            capabilities: { tools: {} }
          }
        }
      end

      def tools_list_response(server, request_id)
        { jsonrpc: "2.0", id: request_id, result: { tools: server.tool_definitions } }
      end

      def tools_call_response(server, request)
        params = request.fetch("params", {})
        result = server.call_tool(params.fetch("name"), params.fetch("arguments", {}))
        content = { type: "text", text: JSON.generate(result) }
        { jsonrpc: "2.0", id: request["id"], result: { content: [content] } }
      end

      def error_response(id, code, message)
        { jsonrpc: "2.0", id: id, error: { code: code, message: message } }
      end

      def request_id(line)
        JSON.parse(line)["id"]
      rescue StandardError
        nil
      end

      def write(output, response)
        output.puts(JSON.generate(response))
        output.flush
      end
    end
  end
end
