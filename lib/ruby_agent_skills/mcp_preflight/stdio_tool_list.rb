# frozen_string_literal: true

module RubyAgentSkills
  module MCPPreflight
    class StdioToolList
      def self.build(result, version)
        tools = result["tools"]
        valid = tools.is_a?(Array) && tools.all? do |tool|
          tool.is_a?(Hash) && tool["name"].is_a?(String)
        end
        raise Error.new("invalid_tools_list", "tools/list must contain named tools") unless valid

        {
          protocol_version: version,
          server_info: safe_server_info(result["serverInfo"]),
          tools: tools.map { |tool| tool["name"] }.uniq.sort
        }
      end

      def self.safe_server_info(info)
        return nil unless info.is_a?(Hash)

        { name: info["name"], version: info["version"] }
      end

      private_class_method :safe_server_info
    end
  end
end
