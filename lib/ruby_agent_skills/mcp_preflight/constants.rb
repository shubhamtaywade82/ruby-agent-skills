# frozen_string_literal: true

module RubyAgentSkills
  module MCPPreflight
    MODERN_PROTOCOL = "2026-07-28"
    LEGACY_PROTOCOL = "2025-11-25"
    DEFAULT_TIMEOUT = 5
    MAX_STDOUT_BUFFER = 1_048_576
    CLIENT_INFO = { "name" => "ruby-agent-skills-preflight", "version" => "1.0.0" }.freeze
    CLIENT_META = {
      "io.modelcontextprotocol/protocolVersion" => MODERN_PROTOCOL,
      "io.modelcontextprotocol/clientCapabilities" => {},
      "io.modelcontextprotocol/clientInfo" => CLIENT_INFO
    }.freeze

    class Error < StandardError
      attr_reader :code

      def initialize(code, message)
        super(message)
        @code = code
      end
    end
  end
end
