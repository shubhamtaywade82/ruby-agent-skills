# frozen_string_literal: true

module RubyAgentSkills
  module MCPPreflight
    class ToolInventory
      MAX_PAGES = 100
      MAX_TOOLS = 10_000

      def self.collect
        tools = []
        seen = {}
        cursor = nil
        page = 0

        loop do
          page += 1
          if page > MAX_PAGES
            raise Error.new("pagination_limit", "tools/list exceeded the page limit")
          end

          result = yield(cursor, page)
          entries = result["tools"]
          validate_page!(entries)
          append_page!(entries, tools, seen)
          cursor = next_cursor(result)
          break if cursor.nil?
        end

        tools
      end

      def self.validate_page!(entries)
        valid = entries.is_a?(Array) && entries.all? do |tool|
          tool.is_a?(Hash) && tool["name"].is_a?(String) && !tool["name"].empty?
        end
        raise Error.new("invalid_tools_list", "tools/list page must contain named tools") unless valid
      end
      private_class_method :validate_page!

      def self.append_page!(entries, tools, seen)
        entries.each do |tool|
          name = tool.fetch("name")
          if seen.key?(name)
            raise Error.new("invalid_tools_list", "tools/list repeated a tool name across pages")
          end
          seen[name] = true
          tools << { "name" => name }
          if tools.length > MAX_TOOLS
            raise Error.new("pagination_limit", "tools/list exceeded the tool limit")
          end
        end
      end
      private_class_method :append_page!

      def self.next_cursor(result)
        cursor = result["nextCursor"]
        return nil if cursor.nil?
        unless cursor.is_a?(String) && !cursor.empty?
          raise Error.new("invalid_tools_list", "tools/list nextCursor must be a non-empty string")
        end

        cursor
      end
      private_class_method :next_cursor
    end
  end
end
