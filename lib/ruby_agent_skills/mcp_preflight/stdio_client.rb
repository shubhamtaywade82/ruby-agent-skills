# frozen_string_literal: true

require "json"

module RubyAgentSkills
  module MCPPreflight
    class StdioClient
      def initialize(stdin, reader, timeout:)
        @stdin = stdin
        @reader = reader
        @timeout = timeout
      end

      def notify_initialized
        write_message("method" => "notifications/initialized", "params" => {})
      end

      def request(id, method, params)
        message = { "id" => id, "method" => method, "params" => params }
        write_message(message)
        @reader.response_for(id, timeout: @timeout)
      rescue IOError, Errno::EPIPE
        raise Error.new("server_exited", "MCP server closed STDIN before responding")
      end

      private

      def write_message(payload)
        message = { "jsonrpc" => "2.0" }.merge(payload)
        @stdin.write(JSON.generate(message))
        @stdin.write("\n")
        @stdin.flush
      end
    end
  end
end
