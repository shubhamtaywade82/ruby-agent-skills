# frozen_string_literal: true

module RubyAgentSkills
  module MCPPreflight
    class ToolInventory
      MAX_PAGES = 100
      MAX_TOOLS = 10_000

      def self.collect
        state = { tools: [], seen: {}, cursor: nil, page: 0 }
        loop do
          state[:page] += 1
          result = yield(state[:cursor], state[:page])
          collect_page(result, state)
          state[:cursor] = next_cursor(result)
          break if state[:cursor].nil?
        end
        state[:tools]
      end

      def self.collect_page(result, state)
        validate_page_limit!(state[:page])
        validate_page!(result["tools"])
        append_page!(result["tools"], state[:tools], state[:seen])
      end
      private_class_method :collect_page

      def self.validate_page_limit!(page)
        return unless page > MAX_PAGES

        raise Error.new("pagination_limit", "tools/list exceeded the page limit")
      end
      private_class_method :validate_page_limit!

      def self.validate_page!(entries)
        valid = entries.is_a?(Array) && entries.all? do |tool|
          tool.is_a?(Hash) && tool["name"].is_a?(String) && !tool["name"].empty?
        end
        return if valid

        raise Error.new("invalid_tools_list", "tools/list page must contain named tools")
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
          enforce_tool_limit!(tools.length)
        end
      end
      private_class_method :append_page!

      def self.enforce_tool_limit!(count)
        return unless count > MAX_TOOLS

        raise Error.new("pagination_limit", "tools/list exceeded the tool limit")
      end
      private_class_method :enforce_tool_limit!

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
