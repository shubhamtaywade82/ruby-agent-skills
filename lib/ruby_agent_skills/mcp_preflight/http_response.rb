# frozen_string_literal: true

require "json"

module RubyAgentSkills
  module MCPPreflight
    class HttpResponse
      def self.parse(response)
        body = response.body.to_s
        body = event_data(body) if response["content-type"].to_s.include?("text/event-stream")
        parsed = JSON.parse(body)
        unless parsed.is_a?(Hash)
          raise Error.new("invalid_protocol_output", "HTTP MCP response must be a JSON object")
        end

        parsed["error"] ? { error: parsed["error"] } : { result: parsed["result"] }
      rescue JSON::ParserError
        raise Error.new("invalid_protocol_output", "HTTP MCP server returned non-JSON data")
      end

      def self.event_data(body)
        body.lines.filter_map do |line|
          line.delete_prefix("data:").strip if line.start_with?("data:")
        end.last.to_s
      end

      def self.server_info(info)
        return nil unless info.is_a?(Hash)

        { name: info["name"], version: info["version"] }
      end

      def self.tools(result)
        list = result["tools"]
        valid = list.is_a?(Array) && list.all? { |tool| tool.is_a?(Hash) && tool["name"].is_a?(String) }
        raise Error.new("invalid_tools_list", "tools/list response must contain named tools") unless valid

        list.map { |tool| tool["name"] }.uniq.sort
      end
    end
  end
end
