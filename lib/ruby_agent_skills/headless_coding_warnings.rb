# frozen_string_literal: true

require "json"
require_relative "headless_output"

module RubyAgentSkills
  # Coding runs keep the CLI's exit status. A failed envelope is a warning,
  # matching the Claude coding adapter.
  module HeadlessCodingWarnings
    module_function

    def warn_for(provider, stdout)
      case provider
      when :cursor then warn_cursor(stdout)
      when :antigravity then warn_antigravity(stdout)
      when :opencode then warn_opencode(stdout)
      end
    end

    def warn_cursor(stdout)
      envelope = JSON.parse(HeadlessOutput.utf8(stdout))
      return unless envelope["is_error"]

      warn "cursor coding run reported an error: #{envelope['result']}"
    rescue JSON::ParserError
      warn "cursor coding run produced non-JSON output"
    end

    def warn_antigravity(stdout)
      envelope = JSON.parse(HeadlessOutput.utf8(stdout))
      return if envelope["status"] == "SUCCESS"

      warn "antigravity coding run reported #{envelope['status']}: #{envelope['error']}"
    rescue JSON::ParserError
      warn "antigravity coding run produced non-JSON output"
    end

    def warn_opencode(stdout)
      errors = error_events(stdout)
      warn "opencode coding run reported an error: #{errors}" unless errors.empty?
    rescue JSON::ParserError
      warn "opencode coding run produced non-JSON output"
    end

    def error_events(stdout)
      HeadlessOutput.json_lines(stdout).select { |event| event["type"] == "error" }
    end
  end
end
