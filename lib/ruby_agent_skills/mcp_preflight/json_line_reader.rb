# frozen_string_literal: true

require "json"

module RubyAgentSkills
  module MCPPreflight
    class JsonLineReader
      def initialize(io)
        @io = io
        @buffer = +""
      end

      def response_for(id, timeout:)
        loop do
          message = next_message(timeout: timeout)
          next unless message["id"] == id

          return { error: message["error"] } if message["error"]

          return { result: message["result"] }
        end
      end

      private

      def next_message(timeout:)
        deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
        loop do
          line = take_line
          return parse_message(line) if line

          remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
          unless remaining.positive?
            raise Error.new("timeout", "timed out waiting for an MCP response")
          end

          read_chunk(remaining)
        end
      end

      def take_line
        newline = @buffer.index("\n")
        return nil unless newline

        line = @buffer.slice!(0..newline).strip
        return take_line if line.empty?

        line
      end

      def parse_message(line)
        message = JSON.parse(line)
        unless message.is_a?(Hash)
          raise Error.new("invalid_protocol_output", "server response must be a JSON object")
        end

        message
      rescue JSON::ParserError
        raise Error.new("invalid_protocol_output", "server wrote non-JSON data to STDOUT")
      end

      def read_chunk(timeout)
        ready = IO.select([@io], nil, nil, timeout)
        raise Error.new("timeout", "timed out waiting for an MCP response") unless ready

        chunk = @io.read_nonblock(16_384, exception: false)
        raise Error.new("server_exited", "MCP server exited before responding") if chunk.nil?

        return if chunk == :wait_readable

        @buffer << chunk
        if @buffer.bytesize > MAX_STDOUT_BUFFER
          raise Error.new("response_too_large", "MCP server response exceeded the 1 MiB limit")
        end
      end
    end
  end
end
